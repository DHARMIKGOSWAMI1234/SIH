# BANDHU Phone Demo Scripts

This directory contains utilities to preview the BANDHU Patient App on a physical phone over the local area network (LAN).

## Files
- `generate_qr.py`: Detects the host PC's active LAN IPv4 address dynamically, rejects loopback addresses (`127.0.0.1`), generates `smriti_phone_demo_qr.png`, and outputs an ASCII QR code to stdout.
- `start_phone_demo.ps1`: Automated PowerShell launcher that verifies prerequisites, detects open ports, triggers QR generation, and launches the Flutter Web server bound to `0.0.0.0`.

## Quick Usage
```powershell
.\scripts\demo\start_phone_demo.ps1
```
Or with custom preferred port:
```powershell
.\scripts\demo\start_phone_demo.ps1 -PreferredPort 9000
```
