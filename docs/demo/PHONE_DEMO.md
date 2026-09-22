# SMRITI — Local Phone Preview & Testing Guide

This guide explains how to run the SMRITI Patient Web Application and preview it directly on any physical smartphone connected to the same local Wi-Fi network.

---

## 1. Prerequisites
- The host PC and test smartphone must be connected to the **same local Wi-Fi router / mobile hotspot**.
- Python 3.13+ installed on host PC.
- Flutter SDK 3.47+ installed on host PC.

---

## 2. One-Click Phone Demo Launcher

Run the automated launcher from the workspace root in PowerShell:

```powershell
.\scripts\demo\start_phone_demo.ps1
```

### What this script does automatically:
1. **Detects Active LAN IPv4:** Queries active network adapters to identify your PC's IP address (e.g., `192.168.1.15`). It explicitly rejects loopback (`127.0.0.1` and `localhost`).
2. **Checks Port Availability:** Checks port `8080` (or selects the next available port if `8080` is busy).
3. **Generates High-Contrast QR Code:** Saves `scripts/demo/smriti_phone_demo_qr.png` and displays an ASCII QR code in the terminal.
4. **Launches Flutter Web Server:** Binds the Flutter web server to `0.0.0.0` at the selected port so phones can connect.

---

## 3. Connecting Your Phone

1. Open the camera or QR code scanner app on your smartphone.
2. Scan the QR code displayed in the terminal or open `scripts/demo/smriti_phone_demo_qr.png`.
3. Tap the link (e.g. `http://192.168.1.15:8080`).
4. SMRITI will load in your mobile browser.

---

## 4. Testing Checklist on Phone
- [ ] **Elderly-First Accessibility:** Verify that body text is large (18sp+), headings are clear, and buttons have generous tap targets (64x64dp+).
- [ ] **High Contrast:** Check text legibility under varied ambient lighting.
- [ ] **Touch Interactions:** Verify that buttons, cards, and navigation items respond immediately without lag.
- [ ] **Memory Match Gameplay:**
  - Navigate to **Games** -> **Memory Match**.
  - Choose **Easy (3 Pairs)**, **Medium (4 Pairs)**, or **Hard (6 Pairs)**.
  - Observe the initial calm card preview (0.5s - 1.5s).
  - Tap card pairs to see the 3D flip animation and match feedback.
  - Test the **Hint** button (glowing card hint).
  - Complete the round to verify the **Results Screen** (accuracy, completion time, score, and adaptive caregiver recommendation).
- [ ] **Activity History:** Navigate to **Progress** tab and verify the completed session is listed with date, accuracy, and score.
- [ ] **Offline Capability:** Toggle phone airplane mode during gameplay or in results to confirm seamless offline SQLite operation.

---

## 5. Stopping the Demo Server
Press `Ctrl + C` in the PowerShell terminal to stop the Flutter Web server.
