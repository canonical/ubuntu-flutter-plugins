/// Safe drop-in replacements for Flutter's `ChangeNotifier` and `ValueNotifier`
/// that make `notifyListeners()` a no-op, rather than an error, after disposal.
///
/// ![safe_change_notifier](https://github.com/ubuntu-flutter-community/safe_change_notifier/raw/main/images/safe_change_notifier.png)
library safe_change_notifier;

export 'src/change_notifier.dart';
export 'src/value_notifier.dart';
