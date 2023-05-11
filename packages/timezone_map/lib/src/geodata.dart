import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:rbush/rbush.dart';
import 'package:xml/xml.dart';

import 'location.dart';
import 'source.dart';

export 'package:latlong2/latlong.dart' show LatLng;

/// https://en.wikipedia.org/wiki/Haversine_formula
final haversine = const Haversine().distance;

/// Performs offline lookups from local geodata from geonames.org:
/// - `admin1CodesASCII.txt`
/// - `cities15000.txt`
/// - `countryInfo.txt`
/// - `timeZones.txt`
class Geodata extends GeoSource {
  /// Constructs a lazily loaded geodata.
  Geodata({
    required FutureOr<String> Function() loadCities,
    required FutureOr<String> Function() loadAdmins,
    required FutureOr<String> Function() loadCountries,
    required FutureOr<String> Function() loadTimezones,
  })  : _loadCities = loadCities,
        _loadAdmins = loadAdmins,
        _loadCountries = loadCountries,
        _loadTimezones = loadTimezones;

  /// Constructs geodata from the package's assets.
  factory Geodata.asset({AssetBundle? bundle}) {
    bundle ??= rootBundle;
    const assetPath = 'packages/timezone_map/assets';
    return Geodata(
      loadCities: () => bundle!.loadString('$assetPath/cities15000.txt'),
      loadAdmins: () => bundle!.loadString('$assetPath/admin1CodesASCII.txt'),
      loadCountries: () => bundle!.loadString('$assetPath/countryInfo.txt'),
      loadTimezones: () => bundle!.loadString('$assetPath/timeZones.txt'),
    );
  }

  final FutureOr<String> Function() _loadCities;
  final FutureOr<String> Function() _loadAdmins;
  final FutureOr<String> Function() _loadCountries;
  final FutureOr<String> Function() _loadTimezones;

  var _initialized = false;
  final _timezones = <String, GeoLocation>{}; // {id: tz}
  final _cities = <String, Set<GeoLocation>>{}; // {city[0]: [cities]}
  late final Map<String, String> _countries2; // {country: code}
  final _coordinates = _GeoBush();

  /// Constructs a [GeoLocation] from [json] data.
  Future<GeoLocation> fromJson(Map<String, dynamic> json) async {
    await _ensureInitialized();
    return GeoLocation(
      name: json.getStringOrNull('name'),
      admin: json.getStringOrNull('admin1'),
      country: json.getStringOrNull('country'),
      country2: json.getStringOrNull('country2', _countries2[json['country']]),
      latitude: json.getDoubleOrNull('latitude'),
      longitude: json.getDoubleOrNull('longitude'),
      timezone: json.getStringOrNull('timezone'),
      offset: _timezones[json.getStringOrNull('timezone')]?.offset,
    );
  }

  /// Constructs a [GeoLocation] from [xml] element.
  Future<GeoLocation?> fromXml(XmlElement xml) async {
    await _ensureInitialized();
    if (xml.getTextOrNull('Status') != 'OK') return null;
    return GeoLocation(
      name: xml.getTextOrNull('City'),
      admin: xml.getTextOrNull('RegionName'),
      country: xml.getTextOrNull('CountryName'),
      country2: xml.getTextOrNull('CountryCode'),
      latitude: xml.getDoubleOrNull('Latitude'),
      longitude: xml.getDoubleOrNull('Longitude'),
      timezone: xml.getTextOrNull('TimeZone'),
      offset: _timezones[xml.getTextOrNull('TimeZone')]?.offset,
    );
  }

  @override
  Future<void> init() => _ensureInitialized();

  @override
  Future<Iterable<GeoLocation>> searchLocation(String location) async {
    await _ensureInitialized();
    final key = location.toSearch();
    if (key.isEmpty) return const <GeoLocation>[];
    return _cities.findWhere(key, (city) => key == city.name?.toSearch());
  }

  @override
  Future<Iterable<GeoLocation>> searchCoordinates(LatLng coords) async {
    await _ensureInitialized();
    return _coordinates.knn(coords.longitude, coords.latitude, 1);
  }

  @override
  Future<Iterable<GeoLocation>> searchTimezone(String timezone) async {
    await _ensureInitialized();
    final key = timezone.toSearch();
    if (key.isEmpty) return _timezones.values;
    return _timezones.values.where((location) {
      return location.timezone?.toSearch().contains(key) == true;
    });
  }

  @override
  Future<void> cancel() async {}

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    // admin code (column 0) and its name (column 1) from admin1CodesASCII.txt
    final admins = _parseMap(await _loadAdmins(), key: 0, value: 1);
    // country code (column 0) and its name (column 4) from countryInfo.txt
    final countries = _parseMap(await _loadCountries(), key: 0, value: 4);

    //final timezones = _parseMap(await _loadTimezones(), key: 1, value: 0);
    // for (final entry in timezones.entries) {
    for (final line in _parseTable(await _loadTimezones())) {
      final countryCode = line[0];
      final timezoneId = line[1];

      // skip invalid lines, such as the header
      if (countryCode.length != 2 || !timezoneId.contains('/')) continue;

      _timezones[timezoneId] = GeoLocation(
        country: countries[line[0]],
        country2: line[0],
        timezone: line[1],
        offset: double.tryParse(line[4]),
      );
    }

    final populations = <String, int>{};

    for (final line in _parseTable(await _loadCities())) {
      if (line.length < 18) continue;

      final city = GeoLocation(
        name: line[1],
        admin: admins['${line[8]}.${line[10]}'],
        country: countries[line[8]],
        country2: line[8],
        latitude: double.tryParse(line[4]),
        longitude: double.tryParse(line[5]),
        timezone: line[17],
        offset: _timezones[line[17]]?.offset,
      );

      // find the largest city in each time zone
      if (city.timezone != null) {
        final population = int.parse(line[14]);
        final tz = populations[city.timezone];
        if (tz == null || tz < population) {
          _timezones[city.timezone!] = city;
          populations[city.timezone!] = population;
        }
      }

      // include alternate city names
      final names = <String>{line[1], ...line[3].split(',')};
      for (final name in names) {
        _cities.insert(name.toSearch(), city.copyWith(name: name));
      }

      if (city.latitude != null && city.longitude != null) {
        _coordinates.insert(city);
      }
    }

    // swap {code: name} to {name: code} for geoip lookup that has no codes
    _countries2 = countries.inverse();
  }
}

// Spatial indexing of coordinates.
class _GeoBush extends RBushBase<GeoLocation> {
  _GeoBush()
      : super(
            toBBox: _HaversineBox.new,
            getMinX: (item) => item.longitude!,
            getMinY: (item) => item.latitude!);
}

class _HaversineBox extends RBushBox {
  _HaversineBox(GeoLocation location)
      : super(
          minX: location.longitude!,
          maxX: location.longitude!,
          minY: location.latitude!,
          maxY: location.latitude!,
        );

  @override
  double distanceSq(double x, double y) {
    return haversine(LatLng(y, x), LatLng(minY, minX));
  }
}

extension _JsonValue on Map<String, dynamic> {
  String? getStringOrNull(String key, [String? fallback]) {
    final value = this[key];
    return value is String ? value : fallback;
  }

  double? getDoubleOrNull(String key) {
    final value = this[key];
    return value is double
        ? value
        : value is String
            ? double.tryParse(value)
            : null;
  }
}

// parses and indexes two columns from tabular data
Map<String, String> _parseMap(
  String data, {
  required int key,
  required int value,
}) {
  final map = <String, String>{};
  for (final line in _parseTable(data)) {
    if (key >= line.length || value >= line.length) continue;
    map[line[key]] = line[value];
  }
  return map;
}

// parses tabular data (assets/*.txt)
Iterable<List<String>> _parseTable(String data) {
  return LineSplitter.split(data).map((line) => line
      .split('#') // ignore comments
      .first
      .split('\t') // tab-separated data
      .toList());
}

// trimmed lowercase string with commas and parentheses etc. removed, suitable
// for searching
extension _SearchString on String {
  // makes a string suitable for searching
  // - trim leading and trailing whitespace
  // - converts to lowercase for case-insensitive matching
  // - remove commas and parentheses etc.
  String toSearch() => trim().toLowerCase().replaceAll(RegExp('[\\W]+'), ' ');
}

extension _InverseMap on Map<String, String> {
  // invert {key: value} to {value: key}
  Map<String, String> inverse<T>() => Map.fromIterables(values, keys);
}

// 1-level "trie" for fast access to all items starting with a specific letter
extension _TrieSet<T> on Map<String, Set<T>> {
  List<T> findWhere(String key, bool Function(T) f) {
    final res = <T>[];
    final values = this[key[0]] ?? <T>[];
    for (final value in values) {
      if (f(value)) res.add(value);
    }
    return res;
  }

  void insert(String key, T value) {
    if (key.isNotEmpty) {
      final k = key[0];
      this[k] ??= <T>{};
      this[k]!.add(value);
    }
  }
}

extension _XmlValue on XmlElement? {
  String? getTextOrNull(String name) => this?.getElement(name)?.innerText;
  double? getDoubleOrNull(String name) =>
      double.tryParse(getTextOrNull(name) ?? '');
}
