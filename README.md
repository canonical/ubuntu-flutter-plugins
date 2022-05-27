# Ubuntu Service

[![pub](https://img.shields.io/pub/v/ubuntu_service.svg)](https://pub.dev/packages/ubuntu_service)
[![CI](https://github.com/ubuntu-flutter-community/ubuntu_service/workflows/Tests/badge.svg)](https://github.com/ubuntu-flutter-community/ubuntu_service/actions/workflows/tests.yaml)
[![codecov](https://codecov.io/gh/ubuntu-flutter-community/ubuntu_service/branch/main/graph/badge.svg)](https://codecov.io/gh/ubuntu-flutter-community/ubuntu_service)

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
