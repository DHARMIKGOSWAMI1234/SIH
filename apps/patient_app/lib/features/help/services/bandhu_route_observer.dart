import 'package:flutter/material.dart';
import '../models/help_screen_id.dart';
import 'help_context_service.dart';

/// NavigatorObserver that monitors page transitions and keeps [HelpContextService] synchronized.
class BandhuRouteObserver extends NavigatorObserver {
  final HelpContextService _service;

  BandhuRouteObserver({HelpContextService? service})
      : _service = service ?? HelpContextService.instance;

  void _handleRoute(Route<dynamic>? route) {
    if (route == null) return;
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) {
      final screenId = HelpScreenId.fromString(name);
      _service.updateFromScreenId(screenId, route: name);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _handleRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _handleRoute(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _handleRoute(newRoute);
  }
}
