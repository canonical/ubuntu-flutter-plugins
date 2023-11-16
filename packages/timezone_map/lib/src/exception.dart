import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

/// Exception thrown for a geo lookup errors.
@immutable
class GeoException<T> implements Exception {
  /// Creates a new exception with [message].
  const GeoException(this.message, [this.error]);

  /// Creates a new exception from a DIO response.
  GeoException.response(Response<T> response)
      : this('${response.statusCode}: ${response.statusMessage}', response);

  /// A message describing the exception.
  final String message;

  /// The originating exception if any.
  final Object? error;

  @override
  String toString() =>
      'GeoException: $message${error != null ? '\n$error' : ''}';

  @override
  int get hashCode => Object.hash(message, error);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoException &&
        other.message == message &&
        other.error == error;
  }
}
