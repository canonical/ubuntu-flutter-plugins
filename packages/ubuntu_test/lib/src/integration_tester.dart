import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Integration test extensions.
extension UbuntuIntegrationTester on WidgetTester {
  /// Pumps until the specified [finder] is satisfied. This can be used to wait
  /// until a certain page or widget becomes visible when it depends on
  /// external conditions.
  Future<void> pumpUntil(
    Finder finder, [
    Duration timeout = const Duration(seconds: 30),
  ]) async {
    assert(binding is LiveTestWidgetsFlutterBinding);

    final sw = Stopwatch()..start();
    final stackTrace = StackTrace.current;

    await Future.doWhile(() async {
      if (any(finder)) return false;
      await pump();
      return sw.elapsed < timeout;
    });

    if (sw.elapsed >= timeout) {
      fail('IntegrationTester.pumpUntil() timed out ($timeout).\n$stackTrace');
    }
  }

  /// Runs the specified application entry-point for integration testing.
  ///
  /// It restores [FlutterError.onError] after calling the specified [entryPoint]
  /// to avoid that integration tests hang due to uncaught timeouts.
  Future<void> runApp(FutureOr<void> Function() entryPoint) async {
    final onError = FlutterError.onError;
    await entryPoint();
    FlutterError.onError = onError;
  }
}
