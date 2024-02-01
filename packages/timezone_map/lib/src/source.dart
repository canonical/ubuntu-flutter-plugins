import 'package:timezone_map/src/location.dart';

/// Geolocation lookup source.
abstract class GeoSource {
  /// Initializes the source.
  Future<void> init() async {}

  /// Looks up the sources and returns current location from the first source
  /// that knows it, if any.
  Future<GeoLocation?> lookupLocation() async => null;

  /// Looks up the sources and returns locations matching the [location], if any.
  Future<Iterable<GeoLocation>> searchLocation(String location) async => [];

  /// Looks up the sources and returns locations near the [coords], if any.
  Future<Iterable<GeoLocation>> searchCoordinates(LatLng coords) async => [];

  /// Looks up the sources and returns timezones matching the [timezone], if any.
  Future<Iterable<GeoLocation>> searchTimezone(String timezone) async => [];

  /// Cancels an ongoing lookup.
  Future<void> cancel() async {}
}
