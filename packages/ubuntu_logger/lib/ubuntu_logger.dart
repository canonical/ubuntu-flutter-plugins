/// A logging frontend based on Google's [logging](https://pub.dev/packages/logging)
/// library for Dart.
///
/// ```dart
/// import 'package:ubuntu_logger/ubuntu_logger.dart';
///
/// final log = Logger('a_context');
///
/// void main() {
///   Logger.setup(
///     path: '/path/to/file.log',
///     level: LogLevel.info,
///   );
///
///   log.debug('This is a debug message.');
///   log.info('This is an info message.');
/// }
/// ```
library ubuntu_logger;

export 'src/ubuntu_logger.dart';
