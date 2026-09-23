import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../features/help/models/help_screen_id.dart';
import '../../features/help/widgets/bandhu_help_button.dart';
import '../../features/help/services/help_context_service.dart';

/// Predictable, high-contrast scaffold for elderly-friendly navigation.
class SmritiScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool showBackButton;
  final HelpScreenId? helpScreenId;
  final bool showHelpButton;

  const SmritiScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.bottomNavigationBar,
    this.showBackButton = true,
    this.helpScreenId,
    this.showHelpButton = true,
  });

  @override
  Widget build(BuildContext context) {
    if (helpScreenId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        HelpContextService.instance.updateFromScreenId(helpScreenId!);
      });
    }

    final canPop = Navigator.canPop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final fgColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final effectiveFab = floatingActionButton ??
        (showHelpButton ? BandhuHelpButton(screenId: helpScreenId) : null);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bgColor,
        leading: (showBackButton && canPop)
            ? IconButton(
                iconSize: 32.0,
                icon: Icon(Icons.arrow_back_rounded, color: fgColor),
                tooltip: 'Go back',
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: fgColor,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        actions: actions,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                .withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200.0),
            child: body,
          ),
        ),
      ),
      floatingActionButton: effectiveFab,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
