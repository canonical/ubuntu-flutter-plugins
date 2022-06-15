import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone_map/timezone_map.dart';

import 'geoip_test.mocks.dart';
import 'test_data.dart';
import 'test_utils.dart';

const kGeoIPUrl = 'http://lookup.geoip.org';

@GenerateMocks([Dio])
void main() {
  test('geoip lookup', () async {
    final dio = MockDio();
    when(dio.get(
      kGeoIPUrl,
      cancelToken: anyNamed('cancelToken'),
    )).thenAnswer((_) async => xmlResponse(copenhagen));

    final geoip = GeoIP(url: kGeoIPUrl, geodata: geodata, dio: dio);

    expect(await geoip.lookupLocation(), copenhagen);
    verify(dio.get(kGeoIPUrl, cancelToken: anyNamed('cancelToken'))).called(1);
  });

  test('geoip error', () async {
    final dio = MockDio();
    when(dio.get(kGeoIPUrl, cancelToken: anyNamed('cancelToken')))
        .thenAnswer((_) async => errorResponse);

    final geoip = GeoIP(url: kGeoIPUrl, geodata: geodata, dio: dio);

    await expectLater(
        () => geoip.lookupLocation(), throwsA(isA<GeoException>()));
  });

  test('invalid geoip data', () async {
    final dio = MockDio();
    when(dio.get(kGeoIPUrl, cancelToken: anyNamed('cancelToken')))
        .thenAnswer((_) async => invalidResponse);

    final geoip = GeoIP(url: kGeoIPUrl, geodata: geodata, dio: dio);

    await expectLater(
        () => geoip.lookupLocation(), throwsA(isA<GeoException>()));
  });

  test('geodata xml', () async {
    expect(
      await geodata.fromXml('''
<Response>
  <Ip>127.0.0.1</Ip>
  <Status>OK</Status>
  <CountryCode>SE</CountryCode>
  <CountryCode3>SWE</CountryCode3>
  <CountryName>Sweden</CountryName>
  <RegionCode>28</RegionCode>
  <RegionName>Vastra Gotaland</RegionName>
  <City>Göteborg</City>
  <ZipPostalCode>416 66</ZipPostalCode>
  <Latitude>57.70716</Latitude>
  <Longitude>11.96679</Longitude>
  <AreaCode>0</AreaCode>
  <TimeZone>Europe/Stockholm</TimeZone>
</Response>
'''),
      gothenburg,
    );

    expect(
      await geodata.fromXml('''
<Response>
  <Ip>127.0.0.1</Ip>
  <Status>OK</Status>
  <City>Göteborg</City>
</Response>
'''),
      const GeoLocation(
        name: 'Göteborg',
        admin: null,
        country: null,
        country2: null,
        latitude: null,
        longitude: null,
        timezone: null,
      ),
    );

    expect(
      await geodata.fromXml('''
<Response>
  <Ip>127.0.0.1</Ip>
  <Status>ERROR</Status>
</Response>
'''),
      isNull,
    );
  });
}

Response xmlResponse(GeoLocation city) {
  return Response(
    data: '''
<Response>
  <Ip>127.0.0.1</Ip>
  <Status>OK</Status>
  <CountryCode>${city.country2}</CountryCode>
  <CountryName>${city.country}</CountryName>
  <RegionName>${city.admin}</RegionName>
  <City>${city.name}</City>
  <Latitude>${city.latitude}</Latitude>
  <Longitude>${city.longitude}</Longitude>
  <TimeZone>${city.timezone}</TimeZone>
  </Response>
''',
    statusCode: 200,
    requestOptions: RequestOptions(path: '/'),
  );
}
