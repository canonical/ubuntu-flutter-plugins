# Platform Linux

[![pub](https://img.shields.io/pub/v/platform_linux.svg)](https://pub.dev/packages/platform_linux)
[![license: MPL](https://img.shields.io/badge/license-MPL-magenta.svg)](https://opensource.org/licenses/MPL-2.0)

Linux-specific extensions on the [platform](https://pub.dev/packages/platform)
package for detecting Linux distro and desktop environment.

## Imports

When used in conjunction with `package:platform`:
```dart
import 'package:platform/platform.dart';
import 'package:platform_linux/platform_linux.dart';
```

Alternatively, with the following syntax, an explicit dependency on
`package:platform` is not required:
```dart
import 'package:platform_linux/platform.dart';
```

## Example

```dart
import 'package:platform_linux/platform.dart';

void main() {
  final platform = LocalPlatform();
  if (platform.isUbuntu && platform.isGNOME) {
    ...
  }
}
```
