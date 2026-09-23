import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme/smriti_theme.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/smriti_scaffold.dart';
import '../../core/widgets/smriti_card.dart';
import '../../core/widgets/smriti_primary_button.dart';
import '../../core/widgets/smriti_secondary_button.dart';
import '../../core/widgets/smriti_section_header.dart';
import '../../core/auth/auth_service.dart';
import 'pairing_service.dart';
import '../help/models/help_screen_id.dart';

class CaregiverConnectionScreen extends StatefulWidget {
  final PatientPairingService? pairingService;

  const CaregiverConnectionScreen({
    super.key,
    this.pairingService,
  });

  @override
  State<CaregiverConnectionScreen> createState() => _CaregiverConnectionScreenState();
}

class _CaregiverConnectionScreenState extends State<CaregiverConnectionScreen> {
  late final PatientPairingService _pairingService;
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _qrPayloadController = TextEditingController();

  bool _isQrMode = false;
  bool _isValidating = false;
  bool _isConfirming = false;
  String? _errorMessage;
  bool _connectedSuccess = false;
  String? _connectedCaregiverName;

  // Live Camera Scanner State
  bool _isCameraActive = false;
  MobileScannerController? _scannerController;
  bool _isTorchOn = false;

  bool get _isTest {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  void _startCamera() {
    HapticFeedback.selectionClick();
    if (!_isTest) {
      _scannerController ??= MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
    }
    setState(() {
      _isCameraActive = true;
      _errorMessage = null;
    });
  }

  void _stopCamera() {
    setState(() {
      _isCameraActive = false;
    });
  }

  void _toggleTorch() {
    if (_scannerController != null && !_isTest) {
      _scannerController!.toggleTorch();
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pairingService = widget.pairingService ?? PatientPairingService();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _qrPayloadController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  void _onDigitPressed(String digit) {
    if (_codeController.text.length < 4) {
      HapticFeedback.lightImpact();
      setState(() {
        _codeController.text += digit;
        _errorMessage = null;
      });
      if (_codeController.text.length == 4) {
        _validateCode(_codeController.text);
      }
    }
  }

  void _onBackspacePressed() {
    if (_codeController.text.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _codeController.text = _codeController.text.substring(0, _codeController.text.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _onClearPressed() {
    HapticFeedback.lightImpact();
    setState(() {
      _codeController.clear();
      _errorMessage = null;
    });
  }

  Future<void> _validateCode(String code) async {
    if (code.length != 4) return;
    setState(() {
      _isValidating = true;
      _errorMessage = null;
    });

    final authService = context.read<AuthService?>();
    final token = authService?.session?.token;

    final result = await _pairingService.validatePairing(
      shortCode: code,
      authToken: token,
    );

    if (!mounted) return;
    setState(() {
      _isValidating = false;
    });

    if (result.valid) {
      _showConfirmationDialog(result);
    } else {
      setState(() {
        _errorMessage = result.error ?? 'Invalid connection code. Please check with your caregiver.';
      });
    }
  }

  Future<void> _validateQrPayload(String payload) async {
    final cleanPayload = payload.trim();
    if (cleanPayload.isEmpty) return;

    setState(() {
      _isValidating = true;
      _errorMessage = null;
    });

    final authService = context.read<AuthService?>();
    final token = authService?.session?.token;

    // Parse payload directly
    final params = PatientPairingService.parseQrPayload(cleanPayload);
    final shortCode = params['code'];
    final pairingToken = params['token'];

    final result = await _pairingService.validatePairing(
      shortCode: shortCode,
      pairingToken: pairingToken,
      qrPayload: cleanPayload,
      authToken: token,
    );

    if (!mounted) return;
    setState(() {
      _isValidating = false;
    });

    if (result.valid) {
      _showConfirmationDialog(result);
    } else {
      setState(() {
        _errorMessage = result.error ?? 'Could not validate QR code. Please verify the code on screen.';
      });
    }
  }

  void _showConfirmationDialog(PairingValidationResult validation) {
    final isDark = SmritiTheme.isDarkMode(context);
    final textPrimary = SmritiTheme.textPrimaryColor(context);
    final textSecondary = SmritiTheme.textSecondaryColor(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          backgroundColor: isDark ? const Color(0xFF1E262B) : Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: SmritiTheme.restorativeSage.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user_rounded, color: SmritiTheme.restorativeSage, size: 28.0),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  'Confirm Caregiver',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: textPrimary),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Would you like to connect with this caregiver?',
                style: TextStyle(fontSize: 15.0, color: textSecondary),
              ),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF273239) : SmritiTheme.sageLight,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : SmritiTheme.borderSubtle,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 20.0, color: SmritiTheme.restorativeSage),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            validation.caregiverName.isNotEmpty ? validation.caregiverName : 'Caregiver',
                            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: textPrimary),
                          ),
                        ),
                      ],
                    ),
                    if (validation.relationship.isNotEmpty) ...[
                      const SizedBox(height: 6.0),
                      Text(
                        'Role: ${validation.relationship}',
                        style: TextStyle(fontSize: 13.0, color: textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14.0),
              Text(
                'Caregiver Permissions:',
                style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: textPrimary),
              ),
              const SizedBox(height: 6.0),
              _buildPermissionItem('View cognitive game activity & comfort trends'),
              _buildPermissionItem('Monitor routine completions & reminders'),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          actions: [
            Row(
              children: [
                Expanded(
                  child: SmritiSecondaryButton(
                    label: 'Cancel',
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: SmritiPrimaryButton(
                    label: 'Connect',
                    icon: Icons.check_rounded,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _executeConfirmation(validation);
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPermissionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 16.0, color: SmritiTheme.restorativeSage),
          const SizedBox(width: 6.0),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, color: SmritiTheme.textSecondaryColor(context)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeConfirmation(PairingValidationResult validation) async {
    final authService = context.read<AuthService?>();
    final session = authService?.session;
    final patientId = session?.patientId ?? session?.userId ?? 'local-patient-demo';
    final token = session?.token;

    setState(() {
      _isConfirming = true;
      _errorMessage = null;
    });

    final res = await _pairingService.confirmPairing(
      pairingToken: validation.pairingToken,
      patientId: patientId,
      authToken: token,
    );

    if (!mounted) return;
    setState(() {
      _isConfirming = false;
    });

    if (res.success) {
      HapticFeedback.mediumImpact();
      setState(() {
        _connectedSuccess = true;
        _connectedCaregiverName = res.caregiverName.isNotEmpty ? res.caregiverName : validation.caregiverName;
      });
    } else {
      setState(() {
        _errorMessage = res.error ?? 'Pairing confirmation failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = SmritiTheme.isDarkMode(context);
    final textPrimary = SmritiTheme.textPrimaryColor(context);
    final textSecondary = SmritiTheme.textSecondaryColor(context);
    final subtleBg = isDark ? const Color(0xFF273239) : SmritiTheme.sageLight;
    final borderColor = isDark ? AppColors.darkBorder : SmritiTheme.borderSubtle;

    return SmritiScaffold(
      title: 'Connect with Caregiver',
      helpScreenId: HelpScreenId.caregiverPairing,
      body: _connectedSuccess
          ? _buildSuccessView(textPrimary, textSecondary)
          : ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                SmritiSectionHeader(
                  title: 'Caregiver Pairing',
                  subtitle: 'Connect your device to your caregiver’s dashboard for gentle monitoring.',
                  icon: Icons.qr_code_scanner_rounded,
                ),
                const SizedBox(height: 12.0),

                // Tab Mode Selector (4-Digit Code vs QR Scanner)
                Container(
                  decoration: BoxDecoration(
                    color: subtleBg,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isQrMode = false;
                              _errorMessage = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(12.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            decoration: BoxDecoration(
                              color: !_isQrMode ? SmritiTheme.restorativeSage : Colors.transparent,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.dialpad_rounded,
                                  size: 18.0,
                                  color: !_isQrMode ? Colors.white : textSecondary,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  '4-Digit Code',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: !_isQrMode ? Colors.white : textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isQrMode = true;
                              _errorMessage = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(12.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            decoration: BoxDecoration(
                              color: _isQrMode ? SmritiTheme.restorativeSage : Colors.transparent,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code_rounded,
                                  size: 18.0,
                                  color: _isQrMode ? Colors.white : textSecondary,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  'Scan QR Code',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: _isQrMode ? Colors.white : textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20.0),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(fontSize: 13.5, color: Colors.red, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],

                if (_isValidating || _isConfirming) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(color: SmritiTheme.restorativeSage),
                          const SizedBox(height: 12.0),
                          Text(
                            _isConfirming ? 'Establishing secure connection...' : 'Verifying connection code...',
                            style: TextStyle(fontSize: 14.0, color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (!_isQrMode) ...[
                  // 4-Digit Code Mode
                  _buildCodeInputBoxes(textPrimary, borderColor, subtleBg),
                  const SizedBox(height: 20.0),
                  _buildKeypad(textPrimary, isDark),
                ] else ...[
                  // QR Scanner Mode
                  _buildQrScannerCard(textPrimary, textSecondary, subtleBg, borderColor),
                ],
              ],
            ),
    );
  }

  Widget _buildCodeInputBoxes(Color textPrimary, Color borderColor, Color subtleBg) {
    final code = _codeController.text;
    return Column(
      children: [
        Text(
          'Enter the 4-digit code shown on the caregiver dashboard:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.5, color: SmritiTheme.textSecondaryColor(context)),
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final hasDigit = index < code.length;
            final digit = hasDigit ? code[index] : '';
            final isCurrent = index == code.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              width: 60.0,
              height: 70.0,
              decoration: BoxDecoration(
                color: hasDigit ? SmritiTheme.restorativeSage.withValues(alpha: 0.12) : subtleBg,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: isCurrent
                      ? SmritiTheme.restorativeSage
                      : hasDigit
                          ? SmritiTheme.restorativeSage
                          : borderColor,
                  width: isCurrent ? 2.5 : 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                digit,
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildKeypad(Color textPrimary, bool isDark) {
    final digits = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['clear', '0', 'backspace'],
    ];

    return Column(
      children: digits.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key == 'backspace') {
                return _buildKeypadButton(
                  onTap: _onBackspacePressed,
                  child: Icon(Icons.backspace_outlined, size: 24.0, color: textPrimary),
                  isDark: isDark,
                );
              } else if (key == 'clear') {
                return _buildKeypadButton(
                  onTap: _onClearPressed,
                  child: Text(
                    'Clear',
                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: textPrimary),
                  ),
                  isDark: isDark,
                );
              } else {
                return _buildKeypadButton(
                  onTap: () => _onDigitPressed(key),
                  child: Text(
                    key,
                    style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: textPrimary),
                  ),
                  isDark: isDark,
                );
              }
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton({
    required VoidCallback onTap,
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      width: 76.0,
      height: 64.0, // Elderly-friendly ≥ 64dp touch target
      child: Material(
        color: isDark ? const Color(0xFF273239) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        elevation: 1.0,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildQrScannerCard(
    Color textPrimary,
    Color textSecondary,
    Color subtleBg,
    Color borderColor,
  ) {
    if (_isCameraActive) {
      return SmritiCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 300.0,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: SmritiTheme.restorativeSage, width: 2.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isTest)
                      Container(
                        color: const Color(0xFF1E262B),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_rounded, size: 54.0, color: SmritiTheme.restorativeSage),
                              SizedBox(height: 8.0),
                              Text(
                                'Simulated Camera View (Test Mode)',
                                style: TextStyle(color: Colors.white, fontSize: 13.0),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_scannerController != null)
                      MobileScanner(
                        controller: _scannerController!,
                        onDetect: (BarcodeCapture capture) {
                          if (_isValidating || _isConfirming || _connectedSuccess) return;
                          for (final barcode in capture.barcodes) {
                            final raw = barcode.rawValue;
                            if (raw != null && raw.trim().isNotEmpty) {
                              HapticFeedback.mediumImpact();
                              _stopCamera();
                              _validateQrPayload(raw);
                              break;
                            }
                          }
                        },
                      ),

                    // Target Viewfinder Frame
                    Container(
                      width: 190.0,
                      height: 190.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: SmritiTheme.restorativeSage, width: 2.5),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),

                    // Controls Header (Flash & Close)
                    Positioned(
                      top: 10.0,
                      left: 10.0,
                      right: 10.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.videocam_rounded, size: 14.0, color: Colors.greenAccent),
                                SizedBox(width: 4.0),
                                Text('Camera Active', style: TextStyle(color: Colors.white, fontSize: 11.5)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                  color: _isTorchOn ? Colors.amber : Colors.white,
                                  size: 20.0,
                                ),
                                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                                onPressed: _toggleTorch,
                              ),
                              const SizedBox(width: 8.0),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20.0),
                                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                                onPressed: _stopCamera,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Instructions Footer
                    Positioned(
                      bottom: 12.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: const Text(
                          'Point camera at Caregiver Dashboard QR code',
                          style: TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            SmritiSecondaryButton(
              label: 'Close Camera Scanner',
              icon: Icons.camera_alt_outlined,
              onPressed: _stopCamera,
            ),
          ],
        ),
      );
    }

    return SmritiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Viewfinder Camera Launcher Box
          InkWell(
            onTap: _startCamera,
            borderRadius: BorderRadius.circular(14.0),
            child: Container(
              height: 190.0,
              decoration: BoxDecoration(
                color: subtleBg,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: borderColor),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 130.0,
                    height: 130.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: SmritiTheme.restorativeSage, width: 2.5),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 56.0,
                        color: SmritiTheme.restorativeSage,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: SmritiTheme.restorativeSage,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_rounded, size: 14.0, color: Colors.white),
                          SizedBox(width: 4.0),
                          Text(
                            'Tap to Open Camera Scanner',
                            style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14.0),
          SmritiPrimaryButton(
            label: 'Open Camera & Scan QR',
            icon: Icons.camera_alt_rounded,
            onPressed: _startCamera,
          ),
          const SizedBox(height: 18.0),
          Divider(color: borderColor),
          const SizedBox(height: 8.0),
          Text(
            'Or Enter / Paste QR Code Payload',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: textPrimary),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Processes the smriti:// URI directly without opening external apps.',
            style: TextStyle(fontSize: 12.0, color: textSecondary),
          ),
          const SizedBox(height: 10.0),
          TextField(
            controller: _qrPayloadController,
            decoration: InputDecoration(
              hintText: 'e.g. smriti://pair?token=...&code=...',
              hintStyle: TextStyle(fontSize: 12.0, color: textSecondary),
              prefixIcon: const Icon(Icons.qr_code_2_rounded, color: SmritiTheme.restorativeSage),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18.0),
                onPressed: () => _qrPayloadController.clear(),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            ),
          ),
          const SizedBox(height: 12.0),
          SmritiSecondaryButton(
            label: 'Process Scanned Code',
            icon: Icons.check_circle_outline_rounded,
            onPressed: () {
              _validateQrPayload(_qrPayloadController.text);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(Color textPrimary, Color textSecondary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88.0,
              height: 88.0,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 54.0),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Connected Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: textPrimary),
            ),
            const SizedBox(height: 10.0),
            Text(
              'Your device is now safely connected to ${_connectedCaregiverName ?? 'your caregiver'}.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.0, color: textSecondary),
            ),
            const SizedBox(height: 32.0),
            SmritiPrimaryButton(
              label: 'Return to Profile',
              icon: Icons.arrow_back_rounded,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      ),
    );
  }
}
