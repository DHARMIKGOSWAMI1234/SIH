"""Database seeder for demo/development environments."""
from sqlalchemy.orm import Session
from backend.api.app.models.user import User, UserRole
from backend.api.app.models.patient import Patient
from backend.api.app.models.caregiver import Caregiver
from backend.api.app.models.patient_caregiver import PatientCaregiver
from backend.api.app.auth.security import get_password_hash
from backend.api.app.core.config import settings

def seed_demo_data(db: Session) -> None:
    """Seed known demo patient and caregiver in development mode."""
    if settings.ENVIRONMENT != "development":
        return

    # 1. Seed demo patient
    demo_user = db.query(User).filter(User.id == "local-patient-demo").first()
    if not demo_user:
        demo_user = User(
            id="local-patient-demo",
            email="local-patient-demo@smriti.care",
            password_hash=get_password_hash("DemoPatient123!"),
            full_name="Local Demo Patient",
            role=UserRole.PATIENT.value,
        )
        db.add(demo_user)
        db.commit()

    demo_patient = db.query(Patient).filter(Patient.id == "local-patient-demo").first()
    if not demo_patient:
        demo_patient = Patient(
            id="local-patient-demo",
            user_id="local-patient-demo",
            anonymous_alias="Demo Patient",
            preferred_language="en",
            font_scale_preference=1.0,
            contrast_preference="standard",
        )
        db.add(demo_patient)
        db.commit()

    # 2. Seed default caregiver
    caregiver_user = db.query(User).filter(User.email == "caregiver@smriti.care").first()
    if not caregiver_user:
        caregiver_user = User(
            id="demo-caregiver-id",
            email="caregiver@smriti.care",
            password_hash=get_password_hash("Caregiver123!"),
            full_name="Primary Demo Caregiver",
            role=UserRole.CAREGIVER.value,
        )
        db.add(caregiver_user)
        db.commit()

    caregiver = db.query(Caregiver).filter(Caregiver.user_id == caregiver_user.id).first()
    if not caregiver:
        caregiver = Caregiver(
            id="demo-caregiver-profile-id",
            user_id=caregiver_user.id,
            full_name="Primary Demo Caregiver",
            phone_number="+91-9876543210",
            relationship_to_patient="Primary Caregiver",
        )
        db.add(caregiver)
        db.commit()

    # 3. Seed caregiver-patient link
    link = (
        db.query(PatientCaregiver)
        .filter(
            PatientCaregiver.patient_id == demo_patient.id,
            PatientCaregiver.caregiver_id == caregiver.id,
        )
        .first()
    )
    if not link:
        link = PatientCaregiver(
            patient_id=demo_patient.id,
            caregiver_id=caregiver.id,
            can_view=True,
            can_edit=False,
        )
        db.add(link)
        db.commit()
