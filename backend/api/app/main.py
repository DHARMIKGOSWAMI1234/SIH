"""SMRITI Backend REST API Service."""
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.api.app.core.config import settings
from backend.api.app.db.base import Base
from backend.api.app.db.session import engine
import backend.api.app.models  # Ensure all models are imported for metadata creation
from backend.api.app.api.v1.health import router as health_router
from backend.api.app.api.v1.auth import router as auth_router
from backend.api.app.api.v1.sync import router as sync_router
from backend.api.app.api.v1.memories import router as memories_router
from backend.api.app.api.v1.caregivers import router as caregivers_router
from backend.api.app.api.v1.analytics import router as analytics_router
from backend.api.app.api.v1.patient_pairing import router as patient_pairing_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize database tables on startup
    Base.metadata.create_all(bind=engine)
    if settings.ENVIRONMENT == "development":
        from backend.api.app.db.seed import seed_demo_data
        from backend.api.app.db.session import SessionLocal
        with SessionLocal() as db:
            seed_demo_data(db)
    yield

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description=(
        "BANDHU Backend API for Cognitive Activity, Routine Support, and Caregiver Transparency. "
        "Strict clinical boundary: This system does NOT perform medical diagnosis or predictive modeling."
    ),
    openapi_url="/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# CORS configuration for local development
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Mount health routers
app.include_router(health_router, prefix="", tags=["System"])
app.include_router(health_router, prefix=settings.API_V1_STR, tags=["System"])

# Mount API v1 feature routers
app.include_router(auth_router, prefix=settings.API_V1_STR)
app.include_router(sync_router, prefix=settings.API_V1_STR)
app.include_router(memories_router, prefix=settings.API_V1_STR)
app.include_router(caregivers_router, prefix=settings.API_V1_STR)
app.include_router(analytics_router, prefix=settings.API_V1_STR)
app.include_router(patient_pairing_router, prefix=settings.API_V1_STR)



if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.api.app.main:app", host=settings.BACKEND_HOST, port=settings.BACKEND_PORT, reload=True)
