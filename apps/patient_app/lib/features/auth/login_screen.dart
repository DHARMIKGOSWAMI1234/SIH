import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/smriti_scaffold.dart';
import '../../core/widgets/smriti_card.dart';
import '../../core/widgets/smriti_primary_button.dart';
import '../../core/widgets/smriti_app_shell.dart';
import '../../core/auth/auth_service.dart';
import '../../l10n/app_strings.dart';

/// Elderly-first, high-contrast Patient Authentication Screen.
/// Supports both Sign In and New Patient Registration with large touch targets.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRegistering = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _selectedLanguage = 'en';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.errorRed,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _localizeErrorMessage(String? error) {
    if (error == null || error.isEmpty) {
      return AppStrings.get('connectionFailed', locale: _selectedLanguage);
    }
    if (error.contains('Internet is required') || error.contains('Internet connection is required')) {
      return AppStrings.get('internetRequiredForRegistration', locale: _selectedLanguage);
    }
    if (error.contains('already exists')) {
      return AppStrings.get('accountAlreadyExists', locale: _selectedLanguage);
    }
    if (error.contains('Server error')) {
      return AppStrings.get('serverError', locale: _selectedLanguage);
    }
    if (error.contains('Something went wrong')) {
      return AppStrings.get('somethingWentWrong', locale: _selectedLanguage);
    }
    if (error.contains('connect') || error.contains('timed out') || error.contains('Network request')) {
      return AppStrings.get('connectionFailed', locale: _selectedLanguage);
    }
    if (error.contains('Invalid email or password') || error.contains('Email or password is incorrect')) {
      return AppStrings.get('invalidCredentials', locale: _selectedLanguage);
    }
    if (error.contains('session has expired') || error.contains('sign in again')) {
      return AppStrings.get('reauthenticatePrompt', locale: _selectedLanguage);
    }
    return error;
  }

  Future<void> _handleSubmit() async {
    final authService = context.read<AuthService>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isRegistering) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        _showError(AppStrings.get('nameRequired', locale: _selectedLanguage));
        return;
      }
    }

    if (email.isEmpty) {
      _showError(AppStrings.get('emailRequired', locale: _selectedLanguage));
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      _showError(AppStrings.get('invalidEmail', locale: _selectedLanguage));
      return;
    }

    if (password.isEmpty || password.length < 6) {
      _showError(AppStrings.get('passwordRequired', locale: _selectedLanguage));
      return;
    }

    bool success = false;
    if (_isRegistering) {
      final name = _nameController.text.trim();
      success = await authService.register(
        email: email,
        password: password,
        fullName: name,
        preferredLanguage: _selectedLanguage,
      );
    } else {
      success = await authService.login(email, password);
    }

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SmritiAppShell(
            currentLocale: authService.session?.preferredLanguage ?? _selectedLanguage,
          ),
        ),
      );
    } else {
      final localizedMsg = _localizeErrorMessage(authService.errorMessage);
      _showError(localizedMsg);
    }
  }

  Future<void> _handleContinueOffline() async {
    final authService = context.read<AuthService>();
    final name = _nameController.text.trim();

    final success = await authService.continueOffline(
      preferredLanguage: _selectedLanguage,
      displayName: name.isNotEmpty ? name : null,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SmritiAppShell(
            currentLocale: _selectedLanguage,
          ),
        ),
      );
    } else {
      _showError(authService.errorMessage ?? 'Failed to start offline mode.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final isLoading = authService.status == AuthStatus.loading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final inputFill = isDark ? AppColors.darkBackground : const Color(0xFFF7F3EA);

    return SmritiScaffold(
      title: _isRegistering
          ? AppStrings.get('registerTitle', locale: _selectedLanguage)
          : AppStrings.get('patientSignIn', locale: _selectedLanguage),
      showBackButton: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSoftBlue : const Color(0xFFEDE9DE),
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: primaryColor,
                    size: 30.0,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isRegistering
                            ? AppStrings.get('registerTitle', locale: _selectedLanguage)
                            : AppStrings.get('welcomeBack', locale: _selectedLanguage),
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        _isRegistering
                            ? AppStrings.get('registerSubtitle', locale: _selectedLanguage)
                            : AppStrings.get('loginSubtitle', locale: _selectedLanguage),
                        style: TextStyle(
                          fontSize: 15.0,
                          color: textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24.0),

            // Mode Selector Toggle (56dp target)
            Container(
              height: 56.0,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: isLoading ? null : () => setState(() => _isRegistering = false),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(14.0)),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: !_isRegistering ? primaryColor : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(14.0)),
                        ),
                        child: Text(
                          AppStrings.get('loginBtn', locale: _selectedLanguage),
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: !_isRegistering
                                ? (isDark ? AppColors.darkBackground : Colors.white)
                                : textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: isLoading ? null : () => setState(() => _isRegistering = true),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(14.0)),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _isRegistering ? primaryColor : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(14.0)),
                        ),
                        child: Text(
                          AppStrings.get('newPatient', locale: _selectedLanguage),
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: _isRegistering
                                ? (isDark ? AppColors.darkBackground : Colors.white)
                                : textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20.0),

            // Form Fields in Accessible Card
            SmritiCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isRegistering) ...[
                    Text(
                      AppStrings.get('fullNameLabel', locale: _selectedLanguage),
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: textPrimary),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _nameController,
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: textPrimary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputFill,
                        hintText: AppStrings.get('fullNameHint', locale: _selectedLanguage),
                        hintStyle: TextStyle(fontSize: 16.0, color: textSecondary.withAlpha(160)),
                        prefixIcon: Icon(Icons.person_outline_rounded, color: primaryColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide(color: borderColor, width: 1.5)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide(color: borderColor, width: 1.5)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide(color: primaryColor, width: 2.0)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      ),
                    ),
                    const SizedBox(height: 18.0),
                  ],

                  Text(
                    AppStrings.get('emailLabel', locale: _selectedLanguage),
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: textPrimary),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputFill,
                      hintText: AppStrings.get('emailHint', locale: _selectedLanguage),
                      hintStyle: TextStyle(fontSize: 16.0, color: textSecondary.withAlpha(160)),
                      prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide(color: borderColor, width: 1.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide(color: borderColor, width: 1.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide(color: primaryColor, width: 2.0)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    ),
                  ),

                  const SizedBox(height: 18.0),

                  Text(
                    AppStrings.get('passwordLabel', locale: _selectedLanguage),
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: textPrimary),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputFill,
                      hintText: AppStrings.get('passwordHint', locale: _selectedLanguage),
                      hintStyle: TextStyle(fontSize: 16.0, color: textSecondary.withAlpha(160)),
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: textSecondary,
                        ),
                        tooltip: _obscurePassword
                            ? AppStrings.get('showPassword', locale: _selectedLanguage)
                            : AppStrings.get('hidePassword', locale: _selectedLanguage),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide(color: borderColor, width: 1.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide(color: borderColor, width: 1.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide(color: primaryColor, width: 2.0)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    ),
                  ),

                  if (_isRegistering) ...[
                    const SizedBox(height: 18.0),
                    Text(
                      AppStrings.get('preferredLanguage', locale: _selectedLanguage),
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: textPrimary),
                    ),
                    const SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedLanguage,
                      dropdownColor: cardColor,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputFill,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide(color: borderColor, width: 1.5)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide(color: borderColor, width: 1.5)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide(color: primaryColor, width: 2.0)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      selectedItemBuilder: (BuildContext context) {
                        return AppStrings.supportedLanguages.map<Widget>((lang) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    lang.nativeName,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                                Flexible(
                                  child: Text(
                                    '(${lang.englishName})',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      items: AppStrings.supportedLanguages.map((lang) {
                        final isSelected = lang.code == _selectedLanguage;
                        return DropdownMenuItem<String>(
                          value: lang.code,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        lang.nativeName,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: isSelected ? primaryColor : textPrimary,
                                        ),
                                        softWrap: true,
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        lang.englishName,
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          color: textSecondary,
                                        ),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 8.0),
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: primaryColor,
                                    size: 20.0,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedLanguage = val);
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28.0),

            // Large Touch Target Primary Button (64dp)
            SmritiPrimaryButton(
              label: isLoading
                  ? AppStrings.get('loading', locale: _selectedLanguage)
                  : (_isRegistering
                      ? AppStrings.get('completeRegistration', locale: _selectedLanguage)
                      : AppStrings.get('signInToSmriti', locale: _selectedLanguage)),
              icon: isLoading ? null : Icons.arrow_forward_rounded,
              onPressed: isLoading ? null : _handleSubmit,
            ),

            const SizedBox(height: 18.0),

            // Accessible OR Divider
            Row(
              children: [
                Expanded(child: Divider(color: borderColor, thickness: 1.5)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    AppStrings.get('orDivider', locale: _selectedLanguage),
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: borderColor, thickness: 1.5)),
              ],
            ),

            const SizedBox(height: 18.0),

            // Elderly-First "Continue Offline" / "Start Without Internet" Button (>= 64dp)
            SmritiPrimaryButton(
              label: AppStrings.get('continueOffline', locale: _selectedLanguage),
              icon: Icons.offline_bolt_rounded,
              backgroundColor: isDark ? const Color(0xFF2E483D) : const Color(0xFF458564),
              textColor: Colors.white,
              onPressed: isLoading ? null : _handleContinueOffline,
            ),

            const SizedBox(height: 20.0),

            // Offline Transparency Note for all users
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi_off_rounded, color: primaryColor, size: 28.0),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.get('offlineReady', locale: _selectedLanguage),
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          AppStrings.get('offlineModeSubtitle', locale: _selectedLanguage),
                          style: TextStyle(
                            fontSize: 13.0,
                            color: textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
