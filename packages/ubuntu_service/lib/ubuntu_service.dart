/// Simple service locator API based on [GetIt](https://pub.dev/packages/get_it).
///
/// ```dart
/// import 'package:ubuntu_service/ubuntu_service.dart';
///
/// void main() {
///   registerService<MyService>(MyService.new);
///   ...
/// }
///
/// void someWhereElse() {
///   final service = getService<MyService>();
///   ...
/// }
/// ```
library ubuntu_service;

export 'src/ubuntu_service.dart';
