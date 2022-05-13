/// A safe drop-in replacement for Flutter's `ChangeNotifier`, that makes
/// `notifyListeners()` a no-op, rather than an error, after its disposal.
///
/// ![safe_change_notifier](https://github.com/ubuntu-flutter-community/safe_change_notifier/raw/main/images/safe_change_notifier.png)
library safe_change_notifier;

import 'package:flutter/foundation.dart';

/// A safe drop-in replacement for Flutter's `ChangeNotifier`, that makes
/// `notifyListeners()` a no-op, rather than an error, after its disposal.
///
/// ![safe_change_notifier](https://github.com/ubuntu-flutter-community/safe_change_notifier/raw/main/images/safe_change_notifier.png)
class SafeChangeNotifier extends ChangeNotifier {
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
