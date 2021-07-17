import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'services.dart';

abstract class Routes {
  Routes._();
  static const String initialPage = welcomePage;
  static const String welcomePage = '/welcome';
  static const String connectPage = '/connect';
  static const String summaryPage = '/summary';

  static Future<String> nextPage(
    BuildContext context, {
    required String route,
  }) async {
    switch (route) {
      case Routes.welcomePage:
        final service = Provider.of<NetworkService>(context, listen: false);
        if (!await service.isConnected()) {
          return Routes.connectPage;
        }
        return Routes.summaryPage;
      case Routes.connectPage:
        return Routes.summaryPage;
      default:
        throw UnimplementedError('Implement Routes.nextRoute() for: $route');
    }
  }
}
