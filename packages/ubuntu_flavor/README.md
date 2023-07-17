# Ubuntu Flavor

[![pub](https://img.shields.io/pub/v/ubuntu_flavor.svg)](https://pub.dev/packages/ubuntu_flavor)
[![license: MPL](https://img.shields.io/badge/license-MPL-magenta.svg)](https://opensource.org/licenses/MPL-2.0)
[![CI](https://github.com/canonical/ubuntu-flutter-plugins/workflows/CI/badge.svg)](https://github.com/canonical/ubuntu-flutter-plugins/actions/workflows/ci.yaml)
[![codecov](https://codecov.io/gh/canonical/ubuntu-flutter-plugins/branch/main/graph/badge.svg)](https://codecov.io/gh/canonical/ubuntu-flutter-plugins)

Detect Ubuntu flavor.

```dart
import 'package:ubuntu_flavor/ubuntu_flavor.dart';

void main() {
  final flavor = UbuntuFlavor.detect();
  print(flavor);
}
```
