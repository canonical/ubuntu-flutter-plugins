# Ubuntu Service

[![pub](https://img.shields.io/pub/v/ubuntu_service.svg)](https://pub.dev/packages/ubuntu_service)
[![license: MPL](https://img.shields.io/badge/license-MPL-magenta.svg)](https://opensource.org/licenses/MPL-2.0)
[![CI](https://github.com/canonical/ubuntu-flutter-plugins/workflows/CI/badge.svg)](https://github.com/canonical/ubuntu-flutter-plugins/actions/workflows/ci.yaml)
[![codecov](https://codecov.io/gh/canonical/ubuntu-flutter-plugins/branch/main/graph/badge.svg)](https://codecov.io/gh/canonical/ubuntu-flutter-plugins)

Simple service locator API based on [GetIt](https://pub.dev/packages/get_it).

```dart
import 'package:ubuntu_service/ubuntu_service.dart';

void main() {
  registerService<MyService>(MyService.new);
  ...
}

void somewhereElse() {
  final service = getService<MyService>();
  ...
}
```
