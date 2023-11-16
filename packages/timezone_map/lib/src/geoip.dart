import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import 'exception.dart';
import 'geodata.dart';
import 'location.dart';
import 'source.dart';

final _options = BaseOptions(
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 5),
  responseType: ResponseType.plain,
);

/// Performs lookups from a geo IP online service (geoip.ubuntu.com/lookup).
class GeoIP extends GeoSource {
  /// Constructs a new [GeoIP] instance.
  GeoIP({
    required this.url,
    required Geodata geodata,
    @visibleForTesting Dio? dio,
  })  : _dio = dio ?? Dio(_options),
        _geodata = geodata;

  /// Constructs a new [GeoIP] with https://geoip.ubuntu.com/lookup.
  factory GeoIP.ubuntu({required Geodata geodata}) {
    return GeoIP(
      url: 'https://geoip.ubuntu.com/lookup',
      geodata: geodata,
    );
  }

  /// GeoIP lookup URL.
  final String url;

  final Dio _dio;
  CancelToken? _token;
  final Geodata _geodata;

  /// Looks up the current geographic location.
  @override
  Future<GeoLocation?> lookupLocation() async {
    await cancel();
    try {
      final response = await _sendRequest();
      return _handleResponse(response);
    } on DioException catch (e) {
      if (!CancelToken.isCancel(e)) {
        throw GeoException(e.message ?? '', e);
      }
    }
    return null;
  }

  /// Cancels an ongoing lookup.
  @override
  Future<void> cancel() async => _token?.cancel();

  Future<Response<T>> _sendRequest<T>() {
    return _dio.get<T>(url, cancelToken: _token = CancelToken());
  }

  Future<GeoLocation?> _handleResponse<T>(Response<T> response) {
    if (response.statusCode != 200) {
      throw GeoException<T>.response(response);
    }
    try {
      final xml = XmlDocument.parse(response.data.toString());
      return _geodata.fromXml(xml.rootElement);
    } on XmlException catch (e) {
      throw GeoException(e.message, e);
    }
  }
}
