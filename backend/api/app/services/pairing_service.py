"""Pairing service for managing secure caregiver-patient linking."""
import secrets
from urllib.parse import urlparse, parse_qs
from datetime import datetime, timezone, timedelta
from typing import Optional, Dict, Any, Tuple
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from backend.api.app.models.caregiver import Caregiver
from backend.api.app.models.patient import Patient
from backend.api.app.models.patient_caregiver import PatientCaregiver
from backend.api.app.models.pairing_request import CaregiverPairingRequest
from backend.api.app.models.user import User

def _to_utc(dt: Optional[datetime]) -> Optional[datetime]:
    if dt is None:
        return None
    if dt.tzinfo is None:
        return dt.replace(tzinfo=timezone.utc)
    return dt.astimezone(timezone.utc)


def _is_expired(expires_at: Optional[datetime]) -> bool:
    if expires_at is None:
        return True
    return _to_utc(expires_at) < datetime.now(timezone.utc)


class PairingService:
    def __init__(self, db: Session):
        self.db = db

    def create_pairing_request(self, caregiver_id: str) -> Tuple[CaregiverPairingRequest, Caregiver]:
        """Generate a random 4-digit code and secure pairing token valid for 10 minutes."""
        caregiver = self.db.query(Caregiver).filter(Caregiver.id == caregiver_id).first()
        if not caregiver:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Caregiver profile not found.",
            )

        now = datetime.now(timezone.utc)

        # Invalidate any previously pending requests for this caregiver
        prev_requests = (
            self.db.query(CaregiverPairingRequest)
            .filter(
                CaregiverPairingRequest.caregiver_id == caregiver_id,
                CaregiverPairingRequest.status == "PENDING",
            )
            .all()
        )
        for pr in prev_requests:
            pr.status = "CANCELLED"

        # Generate a unique 4-digit code among currently active pending requests
        attempts = 0
        short_code = ""
        while attempts < 20:
            candidate = f"{secrets.randbelow(9000) + 1000}"
            pending_requests = (
                self.db.query(CaregiverPairingRequest)
                .filter(
                    CaregiverPairingRequest.short_code == candidate,
                    CaregiverPairingRequest.status == "PENDING",
                )
                .all()
            )
            active_collision = any(not _is_expired(pr.expires_at) for pr in pending_requests)
            if not active_collision:
                short_code = candidate
                break
            attempts += 1

        if not short_code:
            short_code = f"{secrets.randbelow(9000) + 1000}"

        pairing_token = secrets.token_urlsafe(32)
        expires_at = now + timedelta(minutes=10)
        qr_payload = f"smriti://pair?token={pairing_token}&code={short_code}"

        req = CaregiverPairingRequest(
            caregiver_id=caregiver_id,
            short_code=short_code,
            pairing_token=pairing_token,
            qr_payload=qr_payload,
            created_at=now,
            expires_at=expires_at,
            status="PENDING",
        )
        self.db.add(req)
        self.db.commit()
        self.db.refresh(req)
        return req, caregiver

    def get_pairing_status(self, request_id: str, caregiver_id: str) -> Dict[str, Any]:
        """Check status of a pairing request for live dashboard updates."""
        req = (
            self.db.query(CaregiverPairingRequest)
            .filter(
                CaregiverPairingRequest.id == request_id,
                CaregiverPairingRequest.caregiver_id == caregiver_id,
            )
            .first()
        )
        if not req:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Pairing request not found.",
            )

        if req.status == "PENDING" and _is_expired(req.expires_at):
            req.status = "EXPIRED"
            self.db.commit()

        patient_name = None
        if req.patient_id:
            patient = self.db.query(Patient).filter(Patient.id == req.patient_id).first()
            if patient:
                patient_name = patient.anonymous_alias

        return {
            "request_id": req.id,
            "status": req.status,
            "is_used": req.status == "USED",
            "patient_id": req.patient_id,
            "patient_name": patient_name,
        }

    def validate_pairing(
        self,
        short_code: Optional[str] = None,
        pairing_token: Optional[str] = None,
        qr_payload: Optional[str] = None,
    ) -> Tuple[CaregiverPairingRequest, Caregiver]:
        """Validate a 4-digit code or QR token without consuming it yet."""
        # Parse QR payload if passed
        if qr_payload:
            try:
                parsed = urlparse(qr_payload)
                qs = parse_qs(parsed.query)
                if "token" in qs and qs["token"]:
                    pairing_token = qs["token"][0]
                if "code" in qs and qs["code"]:
                    short_code = qs["code"][0]
            except Exception:
                # Fallback: treat entire qr_payload as pairing_token if not a URL
                if not pairing_token:
                    pairing_token = qr_payload.strip()

        req: Optional[CaregiverPairingRequest] = None
        if pairing_token:
            req = (
                self.db.query(CaregiverPairingRequest)
                .filter(CaregiverPairingRequest.pairing_token == pairing_token.strip())
                .first()
            )
        elif short_code:
            clean_code = short_code.strip().replace(" ", "").replace("-", "")
            candidates = (
                self.db.query(CaregiverPairingRequest)
                .filter(
                    CaregiverPairingRequest.short_code == clean_code,
                    CaregiverPairingRequest.status == "PENDING",
                )
                .order_by(CaregiverPairingRequest.created_at.desc())
                .all()
            )
            for c in candidates:
                if not _is_expired(c.expires_at):
                    req = c
                    break

            if not req and candidates:
                req = candidates[0]

        if not req:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Connection code not found. Please verify the 4-digit code.",
            )

        if req.status == "USED":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This connection code has already been used.",
            )

        if req.status == "CANCELLED":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This connection code was replaced by a new one.",
            )

        if _is_expired(req.expires_at) or req.status == "EXPIRED":
            req.status = "EXPIRED"
            self.db.commit()
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This connection code has expired. Please ask your caregiver for a new code.",
            )

        caregiver = self.db.query(Caregiver).filter(Caregiver.id == req.caregiver_id).first()
        if not caregiver:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Associated caregiver profile not found.",
            )

        return req, caregiver

    def confirm_pairing(self, pairing_token: str, patient_id: str) -> Tuple[Caregiver, Patient]:
        """Establish the real caregiver-patient relationship upon explicit patient confirmation."""
        now = datetime.now(timezone.utc)
        req = (
            self.db.query(CaregiverPairingRequest)
            .filter(CaregiverPairingRequest.pairing_token == pairing_token.strip())
            .first()
        )
        if not req:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Pairing request not found.",
            )

        if req.status != "PENDING" or _is_expired(req.expires_at):
            if _is_expired(req.expires_at):
                req.status = "EXPIRED"
                self.db.commit()
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This pairing request is no longer valid or has expired.",
            )

        patient = self.db.query(Patient).filter(Patient.id == patient_id).first()
        if not patient:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Patient record not found.",
            )

        caregiver = self.db.query(Caregiver).filter(Caregiver.id == req.caregiver_id).first()
        if not caregiver:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Caregiver profile not found.",
            )

        # Check or create link in patient_caregivers table
        link = (
            self.db.query(PatientCaregiver)
            .filter(
                PatientCaregiver.patient_id == patient.id,
                PatientCaregiver.caregiver_id == caregiver.id,
            )
            .first()
        )
        if not link:
            link = PatientCaregiver(
                patient_id=patient.id,
                caregiver_id=caregiver.id,
                can_view=True,
                can_edit=False,
                created_at=now,
            )
            self.db.add(link)

        # Mark request as USED
        req.status = "USED"
        req.patient_id = patient.id
        req.used_at = now

        self.db.commit()
        return caregiver, patient

    def get_patient_caregiver(self, patient_id: str) -> Optional[Dict[str, Any]]:
        """Retrieve active linked caregiver information for a patient."""
        link = (
            self.db.query(PatientCaregiver)
            .filter(PatientCaregiver.patient_id == patient_id)
            .order_by(PatientCaregiver.created_at.desc())
            .first()
        )
        if not link:
            return None

        caregiver = self.db.query(Caregiver).filter(Caregiver.id == link.caregiver_id).first()
        if not caregiver:
            return None

        return {
            "connected": True,
            "caregiver_id": caregiver.id,
            "caregiver_name": caregiver.full_name,
            "relationship": caregiver.relationship_to_patient,
            "linked_at": link.created_at.isoformat() if link.created_at else None,
        }
