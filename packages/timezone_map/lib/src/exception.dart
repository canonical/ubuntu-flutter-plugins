import 'package:meta/meta.dart';

/// Exception thrown for a geo lookup errors.
@immutable
class GeoException implements Exception {
  /// Creates a new exception with [message].
  const GeoException(this.message);

  /// A message describing the exception.
  final String message;

  @override
  String toString() => 'GeoException: $message';

  @override
  int get hashCode => message.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoException && other.message == message;
  }
}
