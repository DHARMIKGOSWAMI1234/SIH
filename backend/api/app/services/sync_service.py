"""Synchronization service implementing operation-level idempotency and conflict handling."""
from typing import Dict, Any, Optional
from datetime import datetime, timezone
from sqlalchemy.orm import Session
from backend.api.app.schemas.sync import (
    SyncBatchRequest,
    SyncBatchResponse,
    SyncItemSchema,
    SyncOperationResult,
)
from backend.api.app.models.memory import Memory
from backend.api.app.models.game_session import GameSession
from backend.api.app.models.reminder import Reminder, ReminderEvent
from backend.api.app.models.routine import Routine
from backend.api.app.repositories.user_repository import SyncRepository
from backend.api.app.repositories.entity_repository import (
    MemoryRepository,
    GameRepository,
    ReminderRepository,
    RoutineRepository,
)

class SyncService:
    def __init__(self, db: Session):
        self.db = db
        self.sync_repo = SyncRepository(db)
        self.memory_repo = MemoryRepository(db)
        self.game_repo = GameRepository(db)
        self.reminder_repo = ReminderRepository(db)
        self.routine_repo = RoutineRepository(db)

    def process_batch(self, patient_id: str, items: list[SyncItemSchema]) -> SyncBatchResponse:
        """Process a batch of synchronization operations with strict idempotency."""
        results = []
        now = datetime.now(timezone.utc)

        for item in items:
            # 1. IDEMPOTENCY CHECK
            # Check if this exact operation_id was already processed
            existing_op = self.sync_repo.get_by_operation_id(item.operation_id)
            if existing_op:
                results.append(
                    SyncOperationResult(
                        operation_id=item.operation_id,
                        status="already_processed",
                        server_id=existing_op.server_id,
                        server_updated_at=existing_op.processed_at,
                        message="Operation previously processed and acknowledged",
                    )
                )
                continue

            # 2. DISPATCH TO ENTITY HANDLER
            try:
                result = self._dispatch_item(patient_id, item)
                # Record successful or conflict operation in audit log
                self.sync_repo.record_operation(
                    operation_id=item.operation_id,
                    patient_id=patient_id,
                    entity_type=item.entity_type,
                    operation=item.operation,
                    local_id=item.local_id,
                    server_id=result.server_id,
                    status=result.status,
                    client_updated_at=item.client_updated_at,
                )
                results.append(result)
            except Exception as ex:
                self.db.rollback()
                results.append(
                    SyncOperationResult(
                        operation_id=item.operation_id,
                        status="rejected",
                        message=f"Validation or persistence error: {str(ex)}",
                    )
                )

        return SyncBatchResponse(
            results=results,
            processed_count=len(results),
            server_time=now,
        )

    def _dispatch_item(self, patient_id: str, item: SyncItemSchema) -> SyncOperationResult:
        entity_type = item.entity_type.lower()
        op = item.operation.upper()

        if "memory" in entity_type or "memories" in entity_type:
            return self._sync_memory(patient_id, item, op)
        elif "game" in entity_type:
            return self._sync_game_session(patient_id, item, op)
        elif "reminderevent" in entity_type:
            return self._sync_reminder_event(patient_id, item)
        elif "reminder" in entity_type:
            return self._sync_reminder(patient_id, item, op)
        elif "routine" in entity_type:
            return self._sync_routine(patient_id, item, op)
        else:
            return SyncOperationResult(
                operation_id=item.operation_id,
                status="rejected",
                message=f"Unsupported entity type: {item.entity_type}",
            )

    def _sync_memory(self, patient_id: str, item: SyncItemSchema, op: str) -> SyncOperationResult:
        p = item.payload
        existing = self.memory_repo.get_by_local_id(patient_id, item.local_id)

        if op in ("CREATE", "INSERT"):
            if existing:
                # Already exists locally on server; treat as synced
                return SyncOperationResult(
                    operation_id=item.operation_id,
                    status="synced",
                    server_id=existing.id,
                    server_updated_at=existing.updated_at,
                )
            
            event_date = None
            if p.get("eventDate") or p.get("event_date"):
                raw_dt = p.get("eventDate") or p.get("event_date")
                event_date = datetime.fromisoformat(raw_dt) if isinstance(raw_dt, str) else raw_dt

            now_utc = datetime.now(timezone.utc)
            item_dt = item.client_updated_at or now_utc

            mem = Memory(
                patient_id=patient_id,
                local_id=item.local_id,
                title=p.get("title", "Untitled Memory"),
                description=p.get("description", ""),
                category=p.get("category", "other"),
                relationship=p.get("relationship"),
                person_name=p.get("personName") or p.get("person_name"),
                location=p.get("location"),
                event_date=event_date,
                image_path=p.get("imagePath") or p.get("image_path"),
                audio_path=p.get("audioPath") or p.get("audio_path"),
                media_uri=p.get("mediaUri") or p.get("media_uri"),
                language=p.get("language", "en"),
                region=p.get("region"),
                tags=p.get("tags"),
                source=p.get("source", "personal"),
                is_favorite=bool(p.get("isFavorite", p.get("is_favorite", False))),
                is_archived=bool(p.get("isArchived", p.get("is_archived", False))),
                created_at=item_dt,
                updated_at=item_dt,
            )
            saved = self.memory_repo.create(mem)
            return SyncOperationResult(
                operation_id=item.operation_id,
                status="synced",
                server_id=saved.id,
                server_updated_at=saved.updated_at,
            )

        elif op == "UPDATE":
            if not existing:
                # Create if missing
                return self._sync_memory(patient_id, item, "CREATE")

            # Timestamp / version conflict check
            if item.client_updated_at and existing.updated_at:
                client_dt = item.client_updated_at
                if client_dt.tzinfo is None:
                    client_dt = client_dt.replace(tzinfo=timezone.utc)
                server_dt = existing.updated_at
                if server_dt.tzinfo is None:
                    server_dt = server_dt.replace(tzinfo=timezone.utc)

                if client_dt < server_dt:
                    return SyncOperationResult(
                        operation_id=item.operation_id,
                        status="conflict",
                        server_id=existing.id,
                        server_updated_at=existing.updated_at,
                        message="Server record is newer than client update",
                        conflict_data={
                            "server_title": existing.title,
                            "server_description": existing.description,
                            "server_updated_at": existing.updated_at.isoformat(),
                        },
                    )

            # Apply update
            for field in ["title", "description", "category", "relationship", "location", "language", "region", "tags"]:
                if field in p:
                    setattr(existing, field, p[field])
            if "personName" in p or "person_name" in p:
                existing.person_name = p.get("personName") or p.get("person_name")
            if "isFavorite" in p or "is_favorite" in p:
                existing.is_favorite = bool(p.get("isFavorite", p.get("is_favorite")))
            if "isArchived" in p or "is_archived" in p:
                existing.is_archived = bool(p.get("isArchived", p.get("is_archived")))

            updated = self.memory_repo.update(existing, updated_at=item.client_updated_at)
            return SyncOperationResult(
                operation_id=item.operation_id,
                status="synced",
                server_id=updated.id,
                server_updated_at=updated.updated_at,
            )

        elif op == "DELETE":
            if existing:
                self.memory_repo.delete(existing)
            return SyncOperationResult(
                operation_id=item.operation_id,
                status="synced",
                server_id=existing.id if existing else None,
                server_updated_at=datetime.now(timezone.utc),
            )

        return SyncOperationResult(operation_id=item.operation_id, status="rejected", message=f"Unknown op: {op}")

    VALID_GAME_TYPES = {
        "memory match": "Memory Match",
        "memory_match": "Memory Match",
        "pattern recognition": "Pattern Recognition",
        "pattern_recognition": "Pattern Recognition",
        "daily routine recall": "Daily Routine Recall",
        "daily_routine_recall": "Daily Routine Recall",
    }

    def _sync_game_session(self, patient_id: str, item: SyncItemSchema, op: str) -> SyncOperationResult:
        p = item.payload

        # 1. Validate required identifier fields
        if not item.local_id or not str(item.local_id).strip():
            raise ValueError("Required field 'local_id' cannot be empty")
        if not item.operation_id or not str(item.operation_id).strip():
            raise ValueError("Required field 'operation_id' cannot be empty")

        # 2. Check existing local_id idempotency barrier
        existing = self.game_repo.get_by_local_id(patient_id, item.local_id)
        if existing:
            return SyncOperationResult(
                operation_id=item.operation_id,
                status="synced",
                server_id=existing.id,
                server_updated_at=existing.completed_at,
            )

        # 3. Validate and canonicalize game_type
        raw_game_type = p.get("gameType") or p.get("game_type")
        if not raw_game_type or not str(raw_game_type).strip():
            raise ValueError("Required field 'game_type' is missing or empty")
        norm_game_type = str(raw_game_type).strip().lower()
        if norm_game_type not in self.VALID_GAME_TYPES:
            raise ValueError(
                f"Invalid game type '{raw_game_type}'. Must be one of: Memory Match, Pattern Recognition, Daily Routine Recall"
            )
        canonical_game_type = self.VALID_GAME_TYPES[norm_game_type]

        # 4. Validate numeric ranges
        raw_score = p.get("score")
        if raw_score is None:
            raise ValueError("Required field 'score' is missing")
        try:
            score = int(raw_score)
        except (ValueError, TypeError):
            raise ValueError(f"Score must be an integer, got: {raw_score}")
        if score < 0:
            raise ValueError(f"Score must be non-negative, got: {score}")

        raw_accuracy = p.get("accuracy")
        if raw_accuracy is None:
            raise ValueError("Required field 'accuracy' is missing")
        try:
            accuracy = float(raw_accuracy)
        except (ValueError, TypeError):
            raise ValueError(f"Accuracy must be a float, got: {raw_accuracy}")
        if accuracy < 0.0 or accuracy > 100.0:
            raise ValueError(f"Accuracy must be between 0.0 and 1.0 (or 0 to 100%), got: {accuracy}")


        try:
            mistakes = int(p.get("mistakes", 0))
        except (ValueError, TypeError):
            raise ValueError(f"Mistakes must be an integer, got: {p.get('mistakes')}")
        if mistakes < 0:
            raise ValueError(f"Mistakes must be non-negative, got: {mistakes}")

        try:
            response_time_ms = float(p.get("responseTimeMs") or p.get("response_time_ms", 0.0))
        except (ValueError, TypeError):
            raise ValueError(f"Response time must be numeric, got: {p.get('responseTimeMs') or p.get('response_time_ms')}")
        if response_time_ms < 0:
            raise ValueError(f"Response time must be non-negative, got: {response_time_ms}")

        try:
            difficulty = int(p.get("difficulty", 1))
        except (ValueError, TypeError):
            raise ValueError(f"Difficulty must be an integer, got: {p.get('difficulty')}")
        if difficulty < 1:
            raise ValueError(f"Difficulty must be >= 1, got: {difficulty}")

        try:
            hint_count = int(p.get("hintCount") or p.get("hint_count", 0))
        except (ValueError, TypeError):
            raise ValueError(f"Hint count must be an integer, got: {p.get('hintCount') or p.get('hint_count')}")
        if hint_count < 0:
            raise ValueError(f"Hint count must be non-negative, got: {hint_count}")

        # 5. Validate timestamps
        started_at = p.get("startedAt") or p.get("started_at")
        completed_at = p.get("completedAt") or p.get("completed_at")
        if not started_at or not completed_at:
            raise ValueError("Required timestamps 'started_at' and 'completed_at' must be provided")

        if isinstance(started_at, str):
            try:
                started_at = datetime.fromisoformat(started_at)
            except ValueError as ve:
                raise ValueError(f"Invalid started_at timestamp format: {ve}")
        if isinstance(completed_at, str):
            try:
                completed_at = datetime.fromisoformat(completed_at)
            except ValueError as ve:
                raise ValueError(f"Invalid completed_at timestamp format: {ve}")

        if completed_at < started_at:
            raise ValueError("Completed time cannot be earlier than started time")

        session = GameSession(
            patient_id=patient_id,
            local_id=str(item.local_id),
            game_type=canonical_game_type,
            score=score,
            accuracy=accuracy,
            mistakes=mistakes,
            response_time_ms=response_time_ms,
            difficulty=difficulty,
            hint_count=hint_count,
            started_at=started_at,
            completed_at=completed_at,
        )
        saved = self.game_repo.create(session)
        return SyncOperationResult(
            operation_id=item.operation_id,
            status="synced",
            server_id=saved.id,
            server_updated_at=saved.completed_at,
        )


    def _sync_reminder(self, patient_id: str, item: SyncItemSchema, op: str) -> SyncOperationResult:
        p = item.payload
        existing = self.reminder_repo.get_by_local_id(patient_id, item.local_id)

        if op in ("CREATE", "INSERT"):
            if existing:
                return SyncOperationResult(
                    operation_id=item.operation_id,
                    status="synced",
                    server_id=existing.id,
                    server_updated_at=existing.updated_at,
                )
            reminder = Reminder(
                patient_id=patient_id,
                local_id=item.local_id,
                title=p.get("title", "Reminder"),
                reminder_type=p.get("reminderType") or p.get("reminder_type", "routine"),
                scheduled_time=p.get("scheduledTime") or p.get("scheduled_time", "09:00"),
                enabled=bool(p.get("enabled", True)),
            )
            saved = self.reminder_repo.create(reminder)
            return SyncOperationResult(
                operation_id=item.operation_id,
                status="synced",
                server_id=saved.id,
                server_updated_at=saved.updated_at,
            )
        elif op == "UPDATE":
            if not existing:
                return self._sync_reminder(patient_id, item, "CREATE")
            if "title" in p:
                existing.title = p["title"]
            if "reminderType" in p or "reminder_type" in p:
                existing.reminder_type = p.get("reminderType") or p.get("reminder_type")
            if "scheduledTime" in p or "scheduled_time" in p:
                existing.scheduled_time = p.get("scheduledTime") or p.get("scheduled_time")
            if "enabled" in p:
                existing.enabled = bool(p["enabled"])

            updated = self.reminder_repo.update(existing)
            return SyncOperationResult(
                operation_id=item.operation_id,
                status="synced",
                server_id=updated.id,
                server_updated_at=updated.updated_at,
            )
        elif op == "DELETE":
            if existing:
                self.reminder_repo.delete(existing)
            return SyncOperationResult(
                operation_id=item.operation_id,
                status="synced",
                server_id=existing.id if existing else None,
                server_updated_at=datetime.now(timezone.utc),
            )
        return SyncOperationResult(operation_id=item.operation_id, status="rejected", message=f"Unknown op: {op}")

    def _sync_reminder_event(self, patient_id: str, item: SyncItemSchema) -> SyncOperationResult:
        p = item.payload
        occurred_at = p.get("occurredAt") or p.get("occurred_at")
        if isinstance(occurred_at, str):
            occurred_at = datetime.fromisoformat(occurred_at)

        event = ReminderEvent(
            patient_id=patient_id,
            local_id=item.local_id,
            reminder_id=p.get("reminderId") or p.get("reminder_id", ""),
            event_type=p.get("eventType") or p.get("event_type", "acknowledged"),
            occurred_at=occurred_at or datetime.now(timezone.utc),
        )
        saved = self.reminder_repo.record_event(event)
        return SyncOperationResult(
            operation_id=item.operation_id,
            status="synced",
            server_id=saved.id,
            server_updated_at=saved.occurred_at,
        )

    def _sync_routine(self, patient_id: str, item: SyncItemSchema, op: str) -> SyncOperationResult:
        p = item.payload
        existing = self.routine_repo.get_by_local_id(patient_id, item.local_id)

        if op in ("CREATE", "INSERT"):
            if existing:
                return SyncOperationResult(
                    operation_id=item.operation_id,
                    status="synced",
                    server_id=existing.id,
                    server_updated_at=existing.updated_at,
                )
            routine = Routine(
                patient_id=patient_id,
                local_id=item.local_id,
                title=p.get("title", "Routine"),
                steps_json=p.get("stepsJson") or p.get("steps_json", "[]"),
                preferred_time=p.get("preferredTime") or p.get("preferred_time", "08:00 AM"),
                enabled=bool(p.get("enabled", True)),
            )
            saved = self.routine_repo.create(routine)
            return SyncOperationResult(
                operation_id=item.operation_id,
                status="synced",
                server_id=saved.id,
                server_updated_at=saved.updated_at,
            )
        elif op == "UPDATE":
            if not existing:
                return self._sync_routine(patient_id, item, "CREATE")
            if "title" in p:
                existing.title = p["title"]
            if "stepsJson" in p or "steps_json" in p:
                existing.steps_json = p.get("stepsJson") or p.get("steps_json")
            if "preferredTime" in p or "preferred_time" in p:
                existing.preferred_time = p.get("preferredTime") or p.get("preferred_time")
            if "enabled" in p:
                existing.enabled = bool(p["enabled"])

            updated = self.routine_repo.update(existing)
            return SyncOperationResult(
                operation_id=item.operation_id,
                status="synced",
                server_id=updated.id,
                server_updated_at=updated.updated_at,
            )
        elif op == "DELETE":
            if existing:
                self.routine_repo.delete(existing)
            return SyncOperationResult(
                operation_id=item.operation_id,
                status="synced",
                server_id=existing.id if existing else None,
                server_updated_at=datetime.now(timezone.utc),
            )
        return SyncOperationResult(operation_id=item.operation_id, status="rejected", message=f"Unknown op: {op}")
