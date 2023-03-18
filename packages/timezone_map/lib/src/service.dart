import 'location.dart';
import 'source.dart';

/// Provides geolocation lookups.
class GeoService {
  /// Constructs a service with the given list of geolocation lookup [sources].
  GeoService({List<GeoSource>? sources})
      : _geosources = sources ?? <GeoSource>[];

  final List<GeoSource> _geosources;

  /// Adds a new [source], which is used for searching.
  void addSource(GeoSource source) => _geosources.add(source);

  /// Removes the specified [source].
  void removeSource(GeoSource source) => _geosources.remove(source);

  /// Initializes the sources.
  Future<void> init() {
    return Future.wait([
      for (final source in _geosources) source.init(),
    ]);
  }

  /// Looks up the current geographic location.
  Future<GeoLocation?> lookupLocation() async {
    for (final source in _geosources) {
      final location = await source.lookupLocation();
      if (location != null) {
        return location;
      }
    }
    return null;
  }

  /// Looks up the sources and returns locations matching [location], if any.
  Future<Iterable<GeoLocation>> searchLocation(String location) async {
    final locations = await Future.wait([
      for (final geosource in _geosources) geosource.searchLocation(location),
    ]).then((value) => Set.of(value.expand((locations) => locations)));
    return locations;
  }

  /// Looks up the sources and returns locations near the [coordinates], if any.
  Future<Iterable<GeoLocation>> searchCoordinates(LatLng coordinates) async {
    final locations = await Future.wait([
      for (final geosource in _geosources)
        geosource.searchCoordinates(coordinates),
    ]).then((value) => Set.of(value.expand((locations) => locations)));
    return locations;
  }

  /// Looks up the sources and returns timezones matching [timezone], if any.
  Future<Iterable<GeoLocation>> searchTimezone(String timezone) async {
    final timezones = await Future.wait([
      for (final geosource in _geosources) geosource.searchTimezone(timezone),
    ]).then((value) => Set.of(value.expand((timezones) => timezones)));
    return timezones;
  }

  /// Cancels ongoing lookups.
  Future<void> cancelSearch() {
    return Future.wait([
      for (final geosource in _geosources) geosource.cancel(),
    ]);
  }
}
