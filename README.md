# Ubuntu Flavor

[![pub](https://img.shields.io/pub/v/ubuntu_flavor.svg)](https://pub.dev/packages/ubuntu_flavor)
[![CI](https://github.com/ubuntu-flutter-community/ubuntu_flavor/workflows/CI/badge.svg)](https://github.com/ubuntu-flutter-community/ubuntu_flavor/actions/workflows/ci.yaml)
[![codecov](https://codecov.io/gh/ubuntu-flutter-community/ubuntu_flavor/branch/main/graph/badge.svg)](https://codecov.io/gh/ubuntu-flutter-community/ubuntu_flavor)

Detect Ubuntu flavor.

```dart
import 'package:ubuntu_flavor/ubuntu_flavor.dart';

void main() {
  final flavor = UbuntuFlavor.detect();
  print(flavor);
}
```
