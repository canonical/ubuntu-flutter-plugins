import 'package:flutter/foundation.dart';

import 'notifier_mixin.dart';

/// A safe drop-in replacement for Flutter's `ValueNotifier` that makes
/// `notifyListeners()` a no-op, rather than an error, after its disposal.
///
/// ![safe_change_notifier](https://github.com/ubuntu-flutter-community/safe_change_notifier/raw/main/images/safe_change_notifier.png)
class SafeValueNotifier<T> extends ValueNotifier<T> with SafeNotifierMixin {
  SafeValueNotifier(super.value);
}
