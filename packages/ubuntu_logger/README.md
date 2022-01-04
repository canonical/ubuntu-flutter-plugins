# Ubuntu Logger for Dart

A logging frontend based on Google's [logging](https://pub.dev/packages/logging)
library for Dart.

## Usage

Import the library:

```dart
import 'package:ubuntu_logger/ubuntu_logger.dart';
```

Setup logging:

```dart
void main() {
  Logger.setup(
    path: '/path/to/file.log',
    level: LogLevel.info,
  );
}
```

Log messages:

```dart
final log = Logger('a_context');

log.debug('This is a debug message.');
log.info('This is an info message.');
```

Prints to the console:
```
INFO a_context: This is an info message.
```

Writes to the log file:
```
YYYY-MM-DD HH:MM:SS.zzzzzz INFO a_context: This is an info message.
```
