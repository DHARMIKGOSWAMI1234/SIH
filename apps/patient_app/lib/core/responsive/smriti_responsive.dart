import 'package:flutter/material.dart';

/// Screen type categorization for responsive BANDHU layouts.
enum SmritiScreenType {
  phone,
  tablet,
  desktop;

  bool get isPhone => this == SmritiScreenType.phone;
  bool get isTablet => this == SmritiScreenType.tablet;
  bool get isDesktop => this == SmritiScreenType.desktop;
}

/// Reusable responsive utilities for BANDHU.
/// Breakpoints:
/// - Phone: < 600 px
/// - Tablet: 600 – 1023 px
/// - Desktop: >= 1024 px
class SmritiResponsive {
  static const double phoneBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double maxContentWidth = 1200.0;

  /// Resolves the current screen type from [BuildContext].
  static SmritiScreenType getScreenType(BuildContext context) {
    return getScreenTypeFromWidth(MediaQuery.sizeOf(context).width);
  }

  /// Resolves screen type directly from numeric width in dp.
  static SmritiScreenType getScreenTypeFromWidth(double width) {
    if (width < phoneBreakpoint) {
      return SmritiScreenType.phone;
    } else if (width < tabletBreakpoint) {
      return SmritiScreenType.tablet;
    } else {
      return SmritiScreenType.desktop;
    }
  }

  /// Convenience helpers
  static bool isPhone(BuildContext context) => getScreenType(context).isPhone;
  static bool isTablet(BuildContext context) => getScreenType(context).isTablet;
  static bool isDesktop(BuildContext context) => getScreenType(context).isDesktop;

  /// Adaptive padding based on screen size
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    final type = getScreenType(context);
    switch (type) {
      case SmritiScreenType.phone:
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
      case SmritiScreenType.tablet:
        return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0);
      case SmritiScreenType.desktop:
        return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0);
    }
  }

  /// Adaptive grid column count
  static int getGridColumnCount(BuildContext context, {int phone = 1, int tablet = 2, int desktop = 3}) {
    final type = getScreenType(context);
    switch (type) {
      case SmritiScreenType.phone:
        return phone;
      case SmritiScreenType.tablet:
        return tablet;
      case SmritiScreenType.desktop:
        return desktop;
    }
  }
}

/// A responsive wrapper that constrains content to a maximum width (default 1200dp)
/// and centers it horizontally on large displays, preventing giant stretched layouts.
class SmritiResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const SmritiResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = SmritiResponsive.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? SmritiResponsive.getAdaptivePadding(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}

/// Responsive builder that passes [SmritiScreenType] and [BoxConstraints] to the builder callback.
class SmritiResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, SmritiScreenType screenType, BoxConstraints constraints) builder;

  const SmritiResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final screenType = SmritiResponsive.getScreenType(ctx);
        return builder(ctx, screenType, constraints);
      },
    );
  }
}
