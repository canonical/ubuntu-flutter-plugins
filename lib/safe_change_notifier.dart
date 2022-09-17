/// A safe drop-in replacement for Flutter's `ChangeNotifier`, that makes
/// `notifyListeners()` a no-op, rather than an error, after its disposal.
///
/// ![safe_change_notifier](https://github.com/ubuntu-flutter-community/safe_change_notifier/raw/main/images/safe_change_notifier.png)
library safe_change_notifier;

export 'src/change_notifier.dart';
