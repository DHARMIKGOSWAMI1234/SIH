# SMRITI Automated Cross-Component Test Runner
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "         SMRITI - COMPREHENSIVE VERIFICATION RUNNER         " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"

# 1. AI Adaptive Engine Tests
Write-Host "[1/4] Running AI Adaptive Engine Tests..." -ForegroundColor Yellow
python -m pytest ai/tests
if ($LASTEXITCODE -ne 0) { Write-Error "AI tests failed!" }
Write-Host "      AI tests PASSED." -ForegroundColor Green
Write-Host ""

# 2. Backend API Health Tests
Write-Host "[2/4] Running FastAPI Backend Health Tests..." -ForegroundColor Yellow
python -m pytest backend/api/tests
if ($LASTEXITCODE -ne 0) { Write-Error "Backend tests failed!" }
Write-Host "      Backend tests PASSED." -ForegroundColor Green
Write-Host ""

# 3. Patient App Flutter Tests and Analysis
Write-Host "[3/4] Running Flutter Patient App Analysis and Tests..." -ForegroundColor Yellow
Push-Location apps/patient_app
try {
    flutter analyze
    if ($LASTEXITCODE -ne 0) { Write-Error "Flutter analysis failed!" }
    flutter test
    if ($LASTEXITCODE -ne 0) { Write-Error "Flutter tests failed!" }
} finally {
    Pop-Location
}
Write-Host "      Flutter patient app tests PASSED." -ForegroundColor Green
Write-Host ""

# 4. Dynamic LAN QR Generation Test
Write-Host "[4/4] Verifying Dynamic LAN IP and QR Code Generator..." -ForegroundColor Yellow
python scripts/demo/generate_qr.py --port 8080
if ($LASTEXITCODE -ne 0) { Write-Error "QR generation failed!" }
Write-Host "      QR generation PASSED." -ForegroundColor Green
Write-Host ""

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ALL SMRITI PHASE 01, 02, 03 & 04 TESTS AND CHECKS PASSED! " -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
