import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';
import 'package:meta/meta.dart';

export 'package:latlong2/latlong.dart' show LatLng;

/// Presents a geographic location.
@immutable
class GeoLocation {
  /// Creates a geolocation instance.
  const GeoLocation({
    this.name,
    this.admin,
    this.country,
    this.country2,
    this.latitude,
    this.longitude,
    this.timezone,
    this.offset,
  });

  /// The name of the city.
  final String? name;

  /// The name of the administrative area.
  final String? admin;

  /// The name of the country.
  final String? country;

  /// The ISO-3166 country code.
  final String? country2;

  /// The latitude of the location.
  final double? latitude;

  /// The longitude of the location.
  final double? longitude;

  /// The timezone of the location.
  final String? timezone;

  /// A raw timezone offset without DST.
  final double? offset;

  /// Returns a copy with the specified non-null fields updated.
  GeoLocation copyWith({
    String? name,
    String? admin,
    String? country,
    String? country2,
    double? latitude,
    double? longitude,
    String? timezone,
    double? offset,
  }) {
    return GeoLocation(
      name: name ?? this.name,
      admin: admin ?? this.admin,
      country: country ?? this.country,
      country2: country2 ?? this.country2,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
      offset: offset ?? this.offset,
    );
  }

  @override
  String toString() =>
      'GeoLocation(name: $name, admin: $admin, country: $country, country2: $country2, latitude: $latitude, longitude: $longitude, timezone: $timezone, offset: $offset)';

  /// Formats the location for display (e.g. "San Francisco (California, United States)")
  String toDisplayString() {
    final parts = [name, admin, country].where((s) => s?.isNotEmpty ?? false);
    if (parts.length <= 1) {
      return parts.singleOrNull ?? '';
    } else {
      return '${parts.first} (${parts.skip(1).join(', ')})';
    }
  }

  /// Formats the location's timezone for display (e.g. "America/Los Angeles")
  String toTimezoneString() => (timezone ?? '').replaceAll('_', ' ');

  /// Returns the coordinates if both [latitude] and [longitude] are defined.
  LatLng? get coordinates => latitude != null && longitude != null
      ? LatLng(latitude!, longitude!)
      : null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoLocation &&
        // ignore case-insensitive duplicate alternate names such as "london"
        name?.toLowerCase() == other.name?.toLowerCase() &&
        admin == other.admin &&
        country == other.country &&
        country2 == other.country2 &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        timezone == other.timezone &&
        offset == other.offset;
  }

  @override
  int get hashCode {
    return Object.hash(
      name?.toLowerCase(),
      admin,
      country,
      country2,
      latitude,
      longitude,
      timezone,
      offset,
    );
  }
}
