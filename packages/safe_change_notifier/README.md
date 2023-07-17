# Safe ChangeNotifier

[![pub](https://img.shields.io/pub/v/safe_change_notifier.svg)](https://pub.dev/packages/safe_change_notifier)
[![license: MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![CI](https://github.com/canonical/ubuntu-flutter-plugins/workflows/CI/badge.svg)](https://github.com/canonical/ubuntu-flutter-plugins/actions/workflows/ci.yaml)
[![codecov](https://codecov.io/gh/canonical/ubuntu-flutter-plugins/branch/main/graph/badge.svg)](https://codecov.io/gh/canonical/ubuntu-flutter-plugins)

Safe drop-in replacements for Flutter's `ChangeNotifier` and `ValueNotifier`
that make `notifyListeners()` a no-op, rather than an error, after disposal.

![safe_change_notifier](https://github.com/canonical/ubuntu-flutter-plugins/raw/main/packages/safe_change_notifier/images/safe_change_notifier.png)
