import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:timezone_map/timezone_map.dart';
import 'package:vector_graphics/vector_graphics.dart';

const mapSize = Size(960, 480);

const bottomLeftLatLng = LatLng(-58.73638, -168);
const bottomLeftOffset = Offset(0, 479);

const bottomRightLatLng = LatLng(-58.73638, -168.375);
const bottomRightOffset = Offset(959, 479);

const centerLatLng = LatLng(25.30062, 12);
const centerOffset = Offset(480, 240);

const londonLatLng = LatLng(51.5072, 0.1276);
const londonOffset = Offset(448.34027, 160.50975);

const nullLatLng = LatLng(0, 0);
const nullOffset = Offset(448, 306.74102);

const topLeftLatLng = LatLng(85.545283, -168);
const topLeftOffset = Offset(0, 0);

const topRightLatLng = LatLng(85.545283, -168.375);
const topRightOffset = Offset(959, 0);

Matcher isCloseToOffset(Offset value, [double distance = 1e-5]) {
  return offsetMoreOrLessEquals(value, epsilon: 1e-5);
}

Matcher isCloseToLatLng(
  LatLng value, [
  double distance = 1e-5,
  LengthUnit unit = LengthUnit.Meter,
]) {
  return within(
    from: value,
    distance: distance,
    distanceFunction: (LatLng a, LatLng b) {
      final haversine = const DistanceHaversine().as;
      return haversine(LengthUnit.Kilometer, a, b);
    },
  );
}

extension SvgFinder on CommonFinders {
  Finder svg(String assetName) {
    return find.byWidgetPredicate((widget) {
      return widget is SvgPicture &&
          widget.bytesLoader is AssetBytesLoader &&
          (widget.bytesLoader as AssetBytesLoader)
              .assetName
              .endsWith(assetName);
    });
  }
}

Response jsonResponse(GeoLocation city) {
  return Response(
    data: '''
[
  {
    "name": "${city.name}",
    "admin1": "${city.admin}",
    "country": "${city.country}",
    "country2": "${city.country2}",
    "latitude": "${city.latitude}",
    "longitude": "${city.longitude}",
    "timezone": "${city.timezone}"
  }
]
''',
    statusCode: 200,
    requestOptions: RequestOptions(path: '/'),
  );
}

final errorResponse = Response(
  data: null,
  statusCode: 500,
  requestOptions: RequestOptions(path: '/'),
);

final invalidResponse = Response(
  data: 'invalid',
  statusCode: 200,
  requestOptions: RequestOptions(path: '/'),
);
