import 'package:flutter_test/flutter_test.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

void main() {
  test('dispose', () {
    final notifier = TestSafeStateNotifier(12);
    expect(notifier.isDisposed, isFalse);
    expect(notifier.hasListeners, isFalse);

    var expectedNotifications = 0;
    var actualNotifications = 0;
    void listener(_) => ++actualNotifications;

    final removeListener =
        notifier.addListener(listener, fireImmediately: false);
    expect(notifier.hasListeners, isTrue);

    notifier.setState(34);
    expect(actualNotifications, ++expectedNotifications);

    removeListener();
    expect(notifier.hasListeners, isFalse);

    notifier.setState(56);
    expect(actualNotifications, expectedNotifications);

    notifier.addListener(listener, fireImmediately: false);
    notifier.dispose();
    expect(notifier.isDisposed, isTrue);
    expect(notifier.hasListeners, isFalse);

    expect(() => notifier.setState(78), returnsNormally);
    expect(actualNotifications, expectedNotifications);

    expect(() => notifier.addListener((_) {}), returnsNormally);
    expect(notifier.hasListeners, isFalse);
  });
}

class TestSafeStateNotifier<T> extends SafeStateNotifier<T> {
  TestSafeStateNotifier(super.value);

  void setState(T state) => super.state = state;
}
