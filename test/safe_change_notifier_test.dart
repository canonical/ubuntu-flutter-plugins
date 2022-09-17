import 'package:flutter_test/flutter_test.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

void main() {
  test('dispose', () {
    final notifier = SafeChangeNotifier();
    expect(notifier.isDisposed, isFalse);
    expect(notifier.hasListeners, isFalse);

    var expectedNotifications = 0;
    var actualNotifications = 0;
    void listener() => ++actualNotifications;

    notifier.addListener(listener);
    expect(notifier.hasListeners, isTrue);

    notifier.notifyListeners();
    expect(actualNotifications, ++expectedNotifications);

    notifier.removeListener(listener);
    expect(notifier.hasListeners, isFalse);

    notifier.notifyListeners();
    expect(actualNotifications, expectedNotifications);

    notifier.addListener(listener);
    notifier.dispose();
    expect(notifier.isDisposed, isTrue);
    expect(notifier.hasListeners, isFalse);

    expect(notifier.notifyListeners, returnsNormally);
    expect(actualNotifications, expectedNotifications);

    expect(() => notifier.addListener(() {}), returnsNormally);
    expect(notifier.hasListeners, isFalse);
    expect(() => notifier.removeListener(() {}), returnsNormally);
  });
}
