# Safe ChangeNotifier

[![pub](https://img.shields.io/pub/v/safe_change_notifier.svg)](https://pub.dev/packages/safe_change_notifier)
[![license: MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)
![CI](https://github.com/ubuntu-flutter-community/safe_change_notifier/workflows/CI/badge.svg)
[![codecov](https://codecov.io/gh/ubuntu-flutter-community/safe_change_notifier/branch/main/graph/badge.svg)](https://codecov.io/gh/ubuntu-flutter-community/safe_change_notifier)

A safe drop-in replacement for Flutter's `ChangeNotifier`, that makes
`notifyListeners()` a no-op, rather than an error, after its disposal.

![safe_change_notifier](https://github.com/ubuntu-flutter-community/safe_change_notifier/raw/main/images/safe_change_notifier.png)
