import 'package:flutter/foundation.dart';

import 'package:safe_change_notifier/src/notifier_mixin.dart';

/// A safe drop-in replacement for Flutter's `ChangeNotifier` that makes
/// `notifyListeners()` a no-op, rather than an error, after its disposal.
///
/// ![safe_change_notifier](https://github.com/canonical/ubuntu-flutter-plugins/raw/main/packages/safe_change_notifier/images/safe_change_notifier.png)
class SafeChangeNotifier extends ChangeNotifier with SafeNotifierMixin {}
