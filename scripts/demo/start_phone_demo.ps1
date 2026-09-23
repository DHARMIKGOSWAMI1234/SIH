# BANDHU One-Click Phone Demo Launcher
# SIH26003: AI Cognitive Care Companion

param (
    [int]$PreferredPort = 8080
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "         BANDHU - PHONE DEMO LAUNCHER (LAN PREVIEW)         " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verify Prerequisites
Write-Host "[1/4] Checking prerequisites..." -ForegroundColor Yellow
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter SDK not found in PATH."
}
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error "Python 3 not found in PATH."
}
Write-Host "      Prerequisites verified: Flutter and Python are ready." -ForegroundColor Green

# 2. Check Port Availability
Write-Host "[2/4] Finding available network port..." -ForegroundColor Yellow
$Port = $PreferredPort
while ($true) {
    $portActive = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if ($null -eq $portActive) {
        break
    }
    Write-Host "      Port $Port is busy. Checking next port..." -ForegroundColor DarkYellow
    $Port++
}
Write-Host "      Selected web port: $Port" -ForegroundColor Green

# 3. Generate QR Code
Write-Host "[3/4] Detecting LAN IP and generating high-contrast QR..." -ForegroundColor Yellow
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptPath) {
    $ScriptPath = $PSScriptRoot
}
$qrScript = Join-Path $ScriptPath "generate_qr.py"
python $qrScript --port $Port

# 4. Launch Flutter Web Server
Write-Host "[4/4] Launching BANDHU Web Server..." -ForegroundColor Yellow
Write-Host "      Binding to 0.0.0.0:$Port" -ForegroundColor Cyan
Write-Host "      Press Ctrl+C to stop the server." -ForegroundColor DarkGray
Write-Host ""

$workspaceRoot = (Get-Item $ScriptPath).Parent.Parent.FullName
$patientAppDir = Join-Path $workspaceRoot "apps\patient_app"
$webBuildDir = Join-Path $patientAppDir "build\web"

# If already built, serve instantly via Python; otherwise run flutter web server
if (Test-Path $webBuildDir) {
    Write-Host "      Serving compiled production web bundle instantly..." -ForegroundColor Green
    Push-Location $webBuildDir
    try {
        python -m http.server $Port --bind 0.0.0.0
    } finally {
        Pop-Location
    }
} else {
    Push-Location $patientAppDir
    try {
        flutter run -d web-server --web-hostname 0.0.0.0 --web-port $Port
    } finally {
        Pop-Location
    }
}
