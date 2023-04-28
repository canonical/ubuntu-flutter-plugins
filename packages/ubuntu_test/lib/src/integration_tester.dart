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

    await Future.doWhile(() async {
      if (any(finder)) return false;
      await pump();
      return sw.elapsed < timeout;
    });

    if (sw.elapsed >= timeout) {
      fail('UbuntuIntegrationTester.pumpUntil() timed out ($timeout).');
    }
  }
}
