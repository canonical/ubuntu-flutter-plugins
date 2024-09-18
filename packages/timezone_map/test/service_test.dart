import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone_map/timezone_map.dart';

import 'service_test.mocks.dart';
import 'test_data.dart';
import 'test_utils.dart';

const kGeonameUrl = 'http://lookup.geoname.org';

@GenerateMocks([Dio, GeoSource])
void main() {
  test('service sources', () async {
    final source1 = MockGeoSource();
    when(source1.searchLocation('foo'))
        .thenAnswer((_) async => [copenhagen, gothenburg]);

    final source2 = MockGeoSource();
    when(source2.searchLocation('foo')).thenAnswer((_) async => [copenhagen]);

    final service = GeoService();
    expect(await service.searchLocation('foo'), []);
    verifyNever(source1.searchLocation('foo'));
    verifyNever(source2.searchLocation('foo'));

    service.addSource(source1);
    service.addSource(source2);

    await service.init();
    verify(source1.init()).called(1);
    verify(source2.init()).called(1);

    expect(await service.searchLocation('foo'), [copenhagen, gothenburg]);
    verify(source1.searchLocation('foo')).called(1);
    verify(source2.searchLocation('foo')).called(1);

    service.removeSource(source1);
    expect(await service.searchLocation('foo'), [copenhagen]);
    verifyNever(source1.searchLocation('foo'));
    verify(source2.searchLocation('foo')).called(1);
  });

  test('cancel search', () async {
    final source1 = MockGeoSource();
    when(source1.searchLocation('foo')).thenAnswer((_) async => [gothenburg]);
    when(source1.cancel()).thenAnswer((_) async {});

    final source2 = MockGeoSource();
    when(source2.searchLocation('foo')).thenAnswer((_) async => [gothenburg]);
    when(source2.cancel()).thenAnswer((_) async {});

    final service = GeoService();
    service.addSource(source1);
    service.addSource(source2);
    await service.searchLocation('foo');
    await service.cancelSearch();

    verify(source1.cancel()).called(1);
    verify(source2.cancel()).called(1);
  });

  test('timezones', () async {
    final source1 = MockGeoSource();
    when(source1.searchTimezone('foo'))
        .thenAnswer((_) async => [copenhagen, gothenburg]);

    final source2 = MockGeoSource();
    when(source2.searchTimezone('foo')).thenAnswer((_) async => [copenhagen]);

    final service = GeoService();
    expect(await service.searchTimezone('foo'), []);
    verifyNever(source1.searchTimezone('foo'));
    verifyNever(source2.searchTimezone('foo'));

    service.addSource(source1);
    service.addSource(source2);

    expect(await service.searchTimezone('foo'), [copenhagen, gothenburg]);
    verify(source1.searchTimezone('foo')).called(1);
    verify(source2.searchTimezone('foo')).called(1);

    service.removeSource(source1);
    expect(await service.searchTimezone('foo'), [copenhagen]);
    verifyNever(source1.searchTimezone('foo'));
    verify(source2.searchTimezone('foo')).called(1);
  });

  test('geoname search location', () async {
    final dio = MockDio();
    when(
      dio.get(
        kGeonameUrl,
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).thenAnswer((_) async => jsonResponse(copenhagen));

    final geoname = Geoname(url: kGeonameUrl, geodata: geodata, dio: dio);

    expect(await geoname.searchLocation('foo'), [copenhagen]);
    verify(
      dio.get(
        kGeonameUrl,
        queryParameters: <String, String>{'query': 'foo'},
        cancelToken: anyNamed('cancelToken'),
      ),
    ).called(1);
  });

  test('geoname lang & release', () async {
    final dio = MockDio();
    when(
      dio.get(
        kGeonameUrl,
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).thenAnswer((_) async => jsonResponse(copenhagen));

    final geoname = Geoname(
      url: kGeonameUrl,
      geodata: geodata,
      parameters: {
        'release': 'bar',
        'lang': 'baz',
      },
      dio: dio,
    );

    await geoname.searchLocation('foo');
    verify(
      dio.get(
        kGeonameUrl,
        queryParameters: <String, String>{
          'query': 'foo',
          'release': 'bar',
          'lang': 'baz',
        },
        cancelToken: anyNamed('cancelToken'),
      ),
    ).called(1);
  });

  test('geoname error', () async {
    final dio = MockDio();
    when(
      dio.get(
        kGeonameUrl,
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).thenAnswer((_) async => errorResponse);

    final geoname = Geoname(
      url: kGeonameUrl,
      geodata: geodata,
      parameters: {
        'release': 'bar',
        'lang': 'baz',
      },
      dio: dio,
    );

    await expectLater(
      () => geoname.searchLocation('foo'),
      throwsA(isA<GeoException>()),
    );
  });

  test('invalid geoname data', () async {
    final dio = MockDio();
    when(
      dio.get(
        kGeonameUrl,
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).thenAnswer((_) async => invalidResponse);

    final geoname = Geoname(url: kGeonameUrl, geodata: geodata, dio: dio);

    await expectLater(
      () => geoname.searchLocation('foo'),
      throwsA(isA<GeoException>()),
    );
  });

  test('geolocation copy with', () async {
    final copy1 = copenhagen.copyWith(
      admin: gothenburg.admin,
      country: gothenburg.country,
      longitude: gothenburg.longitude,
      timezone: gothenburg.timezone,
    );
    expect(copy1.name, copenhagen.name);
    expect(copy1.admin, gothenburg.admin);
    expect(copy1.country, gothenburg.country);
    expect(copy1.country2, copenhagen.country2);
    expect(copy1.latitude, copenhagen.latitude);
    expect(copy1.longitude, gothenburg.longitude);
    expect(copy1.timezone, gothenburg.timezone);
    expect(copy1.offset, copenhagen.offset);

    final copy2 = gothenburg.copyWith(
      name: copenhagen.name,
      admin: copenhagen.admin,
      country: copenhagen.country,
      country2: copenhagen.country2,
      latitude: copenhagen.latitude,
      longitude: copenhagen.longitude,
      timezone: copenhagen.timezone,
      offset: copenhagen.offset,
    );
    expect(copy2, copenhagen);

    final copy3 = copenhagen.copyWith();
    expect(copy3, copenhagen);
  });

  test('geolocation string', () {
    final str = copenhagen.toString();
    expect(str.contains(copenhagen.runtimeType.toString()), isTrue);
    expect(str.contains(copenhagen.name!), isTrue);
    expect(str.contains(copenhagen.admin!), isTrue);
    expect(str.contains(copenhagen.country!), isTrue);
    expect(str.contains(copenhagen.country2!), isTrue);
    expect(str.contains(copenhagen.latitude!.toString()), isTrue);
    expect(str.contains(copenhagen.longitude!.toString()), isTrue);
    expect(str.contains(copenhagen.timezone!), isTrue);
  });

  test('geodata location search', () async {
    bool isHelsinki(result) =>
        result.name == 'Helsinki' &&
        result.admin == 'Uusimaa' &&
        result.country == 'Finland';

    bool isOslo(result) =>
        result.name == 'Oslo' &&
        result.admin == 'Oslo' &&
        result.country == 'Norway';

    bool isStockholm(result) =>
        result.name == 'Stockholm' &&
        result.admin == 'Stockholm' &&
        result.country == 'Sweden';

    await geodata
        .searchLocation('')
        .then((results) => expect(results, isEmpty));
    await geodata
        .searchLocation('os')
        .then((results) => expect(results, isEmpty));
    await geodata
        .searchLocation('ST')
        .then((results) => expect(results, isEmpty));
    await geodata
        .searchLocation('Hki')
        .then((results) => expect(results, isEmpty));
    await geodata
        .searchLocation('FIN')
        .then((results) => expect(results, isEmpty));
    await geodata
        .searchLocation('Norway')
        .then((results) => expect(results, isEmpty));
    await geodata
        .searchLocation('Uusimaa')
        .then((results) => expect(results, isEmpty));

    await geodata.searchLocation('oslo').then((results) {
      expect(results, contains(predicate<GeoLocation>(isOslo)));
      expect(results, isNot(contains(predicate<GeoLocation>(isHelsinki))));
      expect(results, isNot(contains(predicate<GeoLocation>(isStockholm))));
    });

    await geodata.searchLocation('STOCKHOLM').then((results) {
      expect(results, contains(predicate<GeoLocation>(isStockholm)));
      expect(results, isNot(contains(predicate<GeoLocation>(isOslo))));
      expect(results, isNot(contains(predicate<GeoLocation>(isHelsinki))));
    });

    await geodata.searchLocation(' Helsinki ').then((results) {
      expect(results, contains(predicate<GeoLocation>(isHelsinki)));
      expect(results, isNot(contains(predicate<GeoLocation>(isOslo))));
      expect(results, isNot(contains(predicate<GeoLocation>(isStockholm))));
    });
  });

  test('alternate names', () async {
    bool isHelsinki(result) =>
        result.name == 'Helsinki' &&
        result.admin == 'Uusimaa' &&
        result.country == 'Finland';

    bool isHelsingfors(result) =>
        result.name == 'Helsingfors' &&
        result.admin == 'Uusimaa' &&
        result.country == 'Finland';

    bool isOslo(result) =>
        result.name == 'Oslo' &&
        result.admin == 'Oslo' &&
        result.country == 'Norway';

    bool isDuplicateOslo(result) =>
        result.name == 'oslo' &&
        result.admin == 'Oslo' &&
        result.country == 'Norway';

    await geodata.searchLocation('helsingfors').then((results) {
      expect(results, isNot(contains(predicate<GeoLocation>(isHelsinki))));
      expect(results, contains(predicate<GeoLocation>(isHelsingfors)));
    });

    await geodata.searchLocation('oslo').then((results) {
      expect(results, contains(predicate<GeoLocation>(isOslo)));
      expect(results, isNot(contains(predicate<GeoLocation>(isDuplicateOslo))));
    });
  });

  test('geodata timezone search', () async {
    await geodata.searchTimezone('').then(
          (results) => expect(
            results,
            equals([copenhagen, helsinki, reykjavik, oslo, stockholm]),
          ),
        );
    await geodata.searchTimezone(' ').then(
          (results) => expect(
            results,
            equals([copenhagen, helsinki, reykjavik, oslo, stockholm]),
          ),
        );
    await geodata
        .searchTimezone('foo')
        .then((results) => expect(results, isEmpty));
    await geodata.searchTimezone('eu').then(
          (results) =>
              expect(results, equals([copenhagen, helsinki, oslo, stockholm])),
        );
    await geodata
        .searchTimezone('ST')
        .then((results) => expect(results, equals([stockholm])));
    await geodata.searchTimezone('Europe').then(
          (results) =>
              expect(results, equals([copenhagen, helsinki, oslo, stockholm])),
        );
    await geodata
        .searchTimezone(' copenhagen ')
        .then((results) => expect(results, equals([copenhagen])));
    await geodata
        .searchTimezone('STOCKHOLM')
        .then((results) => expect(results, equals([stockholm])));
  });

  test('geodata json', () async {
    expect(
      await geodata.fromJson(<String, dynamic>{
        'name': 'Copenhagen',
        'admin1': 'Capital Region',
        'country': 'Denmark',
        'latitude': '55.67594',
        'longitude': '12.56553',
        'timezone': 'Europe/Copenhagen',
      }),
      copenhagen,
    );

    expect(
      await geodata.fromJson(<String, dynamic>{
        'latitude': 55.67594,
        'longitude': 12.56553,
      }),
      const GeoLocation(
        latitude: 55.67594,
        longitude: 12.56553,
      ),
    );
  });
}
