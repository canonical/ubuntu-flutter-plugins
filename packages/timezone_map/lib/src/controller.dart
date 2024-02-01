import 'package:safe_change_notifier/safe_change_notifier.dart';

import 'package:timezone_map/src/location.dart';
import 'package:timezone_map/src/service.dart';

/// Controls a timezone map widget.
class TimezoneController extends SafeChangeNotifier {
  /// Creates a controller with the given [service].
  TimezoneController({
    required GeoService service,
    GeoLocation? selectedLocation,
  })  : _service = service,
        _selectedLocation = selectedLocation;

  final GeoService _service;

  LatLng? _lastCoordinates;
  String? _lastLocation;
  String? _lastTimezone;
  GeoLocation? _selectedLocation;
  Iterable<GeoLocation> _locations = const <GeoLocation>[];
  Iterable<GeoLocation> _timezones = const <GeoLocation>[];

  /// The currently selected location.
  GeoLocation? get selectedLocation => _selectedLocation;

  /// The list of locations that match the current search criteria.
  Iterable<GeoLocation> get locations => _locations;

  /// The list of timezones that match the current search criteria.
  Iterable<GeoLocation> get timezones => _timezones;

  /// Selects the given [location].
  void selectLocation(GeoLocation? location) {
    if (_selectedLocation == location) return;
    _selectedLocation = location;
    _lastLocation = null;
    notifyListeners();
  }

  /// Selects the given [timezone].
  void selectTimezone(GeoLocation? timezone) {
    if (_selectedLocation == timezone) return;
    _selectedLocation = timezone;
    _lastTimezone = null;
    notifyListeners();
  }

  Iterable<GeoLocation> _updateLocations(Iterable<GeoLocation> locations) {
    _locations = locations;
    notifyListeners();
    return _locations;
  }

  Iterable<GeoLocation> _updateTimezones(Iterable<GeoLocation> timezones) {
    _timezones = timezones;
    notifyListeners();
    return _timezones;
  }

  /// Searches for locations that match the given [location] name.
  Future<Iterable<GeoLocation>> searchLocation(String location) async {
    if (location.isEmpty) return const <GeoLocation>[];
    if (_lastLocation == location) return _locations;
    _lastLocation = location;
    return _service
        .searchLocation(location)
        .then(_updateLocations)
        .catchError((_) => _locations);
  }

  /// Searches for locations that are closest the given [coordinates].
  Future<Iterable<GeoLocation>> searchCoordinates(LatLng coordinates) async {
    if (_lastCoordinates == coordinates) return _locations;
    _lastCoordinates = coordinates;
    return _service
        .searchCoordinates(coordinates)
        .then(_updateLocations)
        .catchError((_) => _locations);
  }

  /// Searches for locations that match the given [timezone] name.
  Future<Iterable<GeoLocation>> searchTimezone(String timezone) async {
    if (_lastTimezone == timezone) return _timezones;
    _lastTimezone = timezone;
    return _service
        .searchTimezone(timezone)
        .then(_updateTimezones)
        .catchError((_) => _timezones);
  }
}
