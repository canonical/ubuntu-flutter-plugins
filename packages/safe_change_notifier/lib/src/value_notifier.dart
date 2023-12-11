import 'package:flutter/foundation.dart';

import 'package:safe_change_notifier/src/notifier_mixin.dart';

/// A safe drop-in replacement for Flutter's `ValueNotifier` that makes
/// `notifyListeners()` a no-op, rather than an error, after its disposal.
///
/// ![safe_change_notifier](https://github.com/canonical/ubuntu-flutter-plugins/raw/main/packages/safe_change_notifier/images/safe_change_notifier.png)
class SafeValueNotifier<T> extends ValueNotifier<T> with SafeNotifierMixin {
  SafeValueNotifier(super.value);
}
