/// Safe drop-in replacements for Flutter's `ChangeNotifier` and `ValueNotifier`
/// that make `notifyListeners()` a no-op, rather than an error, after disposal.
///
/// ![safe_change_notifier](https://github.com/canonical/ubuntu-flutter-plugins/raw/main/packages/safe_change_notifier/images/safe_change_notifier.png)
library;

export 'src/change_notifier.dart';
export 'src/state_notifier.dart';
export 'src/value_notifier.dart';
