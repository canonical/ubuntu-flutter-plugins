import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'services.dart';

abstract class Routes {
  Routes._();
  static const String initial = welcome;
  static const String welcome = '/welcome';
  static const String connect = '/connect';
  static const String summary = '/summary';

  static Future<String> nextRoute(
    BuildContext context, {
    required String route,
  }) async {
    switch (route) {
      case Routes.welcome:
        final service = Provider.of<NetworkService>(context, listen: false);
        if (!await service.isConnected()) {
          return Routes.connect;
        }
        return Routes.summary;
      case Routes.connect:
        return Routes.summary;
      default:
        throw UnimplementedError('Implement Routes.nextRoute() for: $route');
    }
  }
}
