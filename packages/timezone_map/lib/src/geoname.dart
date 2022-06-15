import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'exception.dart';
import 'geodata.dart';
import 'location.dart';
import 'source.dart';

final _options = BaseOptions(
  connectTimeout: 1000,
  receiveTimeout: 1000,
  responseType: ResponseType.plain,
);

/// Performs online lookups from a geoname service (geoname-lookup.ubuntu.com).
class Geoname extends GeoSource {
  /// Constructs a new [Geoname] instance.
  Geoname({
    required this.url,
    required Geodata geodata,
    this.parameters,
    @visibleForTesting Dio? dio,
  })  : _dio = dio ?? Dio(_options),
        _geodata = geodata;

  /// Constructs a new [Geoname] with https://geoname-lookup.ubuntu.com.
  factory Geoname.ubuntu({
    required Geodata geodata,
    Map<String, String>? parameters,
  }) {
    return Geoname(
      url: 'https://geoname-lookup.ubuntu.com/',
      geodata: geodata,
      parameters: parameters,
    );
  }

  /// The URL of the geoname service.
  String url;

  /// The parameters for the geoname service, e.g. {release: jammy, lang: en}.
  Map<String, String>? parameters;

  final Dio _dio;
  CancelToken? _token;
  final Geodata _geodata;

  @override
  Future<Iterable<GeoLocation>> searchLocation(String location) async {
    await cancel();
    try {
      final response = await _sendRequest(location);
      return _handleResponse(response);
    } on DioError catch (e) {
      if (!CancelToken.isCancel(e) && e.error is! SocketException) {
        throw GeoException(e.message);
      }
    }
    return const <GeoLocation>[];
  }

  @override
  Future<void> cancel() async => _token?.cancel();

  Future<Response> _sendRequest(String query) {
    return _dio.get(
      url,
      queryParameters: <String, String>{'query': query, ...?parameters},
      cancelToken: _token = CancelToken(),
    );
  }

  Future<Iterable<GeoLocation>> _handleResponse(Response response) async {
    if (response.statusCode != 200) {
      throw GeoException('${response.statusCode}: ${response.statusMessage}');
    }
    try {
      final data = json.decode(response.data.toString());
      if (data is! Iterable) throw const FormatException();
      final locations = data.cast<Map<String, dynamic>>();
      return Future.wait(locations.map(_geodata.fromJson));
    } on FormatException catch (e) {
      throw GeoException(e.message);
    }
  }
}
