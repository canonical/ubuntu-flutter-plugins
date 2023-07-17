import 'package:flutter/foundation.dart';

/// A safe mixin for Flutter's `ChangeNotifier` and `ValueNotifier` that makes
/// `notifyListeners()` a no-op, rather than an error, after disposal.
///
/// ![safe_change_notifier](https://github.com/canonical/ubuntu-flutter-plugins/raw/main/packages/safe_change_notifier/images/safe_change_notifier.png)
mixin SafeNotifierMixin on ChangeNotifier {
  var _isDisposed = false;

  /// Whether the notifier has been disposed.
  bool get isDisposed => _isDisposed;

  @override
  bool get hasListeners => !_isDisposed && super.hasListeners;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void addListener(VoidCallback listener) {
    if (!_isDisposed) {
      super.addListener(listener);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    if (!_isDisposed) {
      super.removeListener(listener);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
