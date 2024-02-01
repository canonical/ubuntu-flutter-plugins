import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone_map/timezone_map.dart';

import 'controller_test.mocks.dart';

@GenerateMocks([GeoService])
void main() {
  test('select location', () async {
    const location = GeoLocation(name: 'Helsinki, Finland');

    final service = MockGeoService();

    final model = TimezoneController(service: service);
    expect(model.selectedLocation, isNull);

    bool? wasNotified;
    model.addListener(() => wasNotified = true);

    model.selectLocation(location);
    expect(model.selectedLocation, equals(location));
    expect(wasNotified, isTrue);
  });

  test('select timezone', () async {
    const location = GeoLocation(name: 'Helsinki, Finland');

    final service = MockGeoService();

    final model = TimezoneController(service: service);
    expect(model.selectedLocation, isNull);

    bool? wasNotified;
    model.addListener(() => wasNotified = true);

    model.selectTimezone(location);
    expect(model.selectedLocation, equals(location));
    expect(wasNotified, isTrue);
  });

  test('search location', () async {
    const location = GeoLocation(name: 'Copenhagen', country: 'Denmark');

    final service = MockGeoService();
    when(service.searchLocation('Copenhagen'))
        .thenAnswer((_) async => [location]);
    when(service.searchLocation('Denmark')).thenAnswer((_) async => [location]);

    final model = TimezoneController(service: service);
    model.selectLocation(const GeoLocation());
    expect(model.selectedLocation, isNotNull);
    expect(model.locations, isEmpty);

    final locations = await model.searchLocation(location.name!);
    expect(locations, equals([location]));
    verify(service.searchLocation(location.name)).called(1);

    await model.searchLocation(location.name!);
    expect(model.locations, equals([location]));
    verifyNever(service.searchLocation(location.name));

    await model.searchLocation(location.country!);
    verify(service.searchLocation(location.country)).called(1);
  });

  test('search timezone', () async {
    const location = GeoLocation(
      name: 'Copenhagen',
      country: 'Denmark',
      country2: 'DK',
      timezone: 'Europe/Copenhagen',
    );

    final service = MockGeoService();
    when(service.searchTimezone(location.timezone))
        .thenAnswer((_) async => [location]);

    final model = TimezoneController(service: service);
    model.selectTimezone(const GeoLocation());
    expect(model.selectedLocation, isNotNull);
    expect(model.locations, isEmpty);

    final timezones = await model.searchTimezone(location.timezone!);
    expect(timezones, equals([location]));
    verify(service.searchTimezone(location.timezone)).called(1);

    await model.searchTimezone(location.timezone!);
    expect(model.timezones, equals([location]));
    verifyNever(service.searchTimezone(location.timezone));
  });

  test('search coordinates', () async {
    const locations = [
      GeoLocation(name: 'foo', latitude: 12, longitude: 34),
      GeoLocation(name: 'bar', latitude: 56, longitude: 78)
    ];

    final service = MockGeoService();
    when(service.searchCoordinates(any)).thenAnswer((_) async => locations);

    final model = TimezoneController(service: service);
    expect(
        await model.searchCoordinates(const LatLng(56, 78)), equals(locations));
    verify(service.searchCoordinates(const LatLng(56, 78))).called(1);
  });
}
