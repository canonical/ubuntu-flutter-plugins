import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:timezone_map/timezone_map.dart';

import 'test_utils.dart';

void main() {
  Widget buildMap(
    WidgetTester tester, {
    Size? size,
    double? offset,
    LatLng? coordinates,
    void Function(LatLng)? onPressed,
  }) {
    tester.binding.window.devicePixelRatioTestValue = 1;
    tester.binding.window.physicalSizeTestValue = size ?? mapSize;

    return MaterialApp(
      home: Scaffold(
        body: SizedBox.expand(
          child: TimezoneMap(
            offset: offset,
            marker: coordinates,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  testWidgets('map', (tester) async {
    await tester.pumpWidget(buildMap(tester));
    expect(find.svg('map.svg.vec'), findsOneWidget);
  });

  testWidgets('press', (tester) async {
    LatLng? pressed;

    await tester.pumpWidget(
      buildMap(tester, onPressed: (coords) => pressed = coords),
    );

    await tester.tap(find.byType(TimezoneMap));
    expect(pressed, isCloseToLatLng(centerLatLng));

    await tester.tapAt(londonOffset);
    expect(pressed, isCloseToLatLng(londonLatLng));

    await tester.tapAt(nullOffset);
    expect(pressed, isCloseToLatLng(nullLatLng));

    await tester.tapAt(topLeftOffset);
    expect(pressed, isCloseToLatLng(topLeftLatLng));

    await tester.tapAt(topRightOffset);
    expect(pressed, isCloseToLatLng(topRightLatLng));

    await tester.tapAt(bottomLeftOffset);
    expect(pressed, isCloseToLatLng(bottomLeftLatLng));

    await tester.tapAt(bottomRightOffset);
    expect(pressed, isCloseToLatLng(bottomRightLatLng));
  });

  testWidgets('marker', (tester) async {
    await tester.pumpWidget(buildMap(tester, coordinates: londonLatLng));
    expect(find.byIcon(Icons.place), findsOneWidget);

    // Rect.contains() excludes bottom and right edges
    final iconRect = tester.getRect(find.byIcon(Icons.place)).inflate(1);
    expect(iconRect.contains(londonOffset), isTrue);

    await tester.pumpWidget(buildMap(tester, coordinates: null));
    expect(find.byIcon(Icons.place), findsNothing);
  });

  testWidgets('offset', (tester) async {
    await tester.pumpWidget(buildMap(tester, offset: 1));
    expect(find.svg('tz_0.svg.vec'), findsNothing);
    expect(find.svg('tz_1.svg.vec'), findsOneWidget);
    expect(find.svg('tz_-1.svg.vec'), findsNothing);

    await tester.pumpWidget(buildMap(tester, offset: null));
    expect(find.svg('tz_0.svg.vec'), findsNothing);
    expect(find.svg('tz_1.svg.vec'), findsNothing);
    expect(find.svg('tz_-1.svg.vec'), findsNothing);

    await tester.pumpWidget(buildMap(tester, offset: -1));
    expect(find.svg('tz_0.svg.vec'), findsNothing);
    expect(find.svg('tz_1.svg.vec'), findsNothing);
    expect(find.svg('tz_-1.svg.vec'), findsOneWidget);

    await tester.pumpWidget(buildMap(tester, offset: -3.5));
    expect(find.svg('tz_-3.5.svg.vec'), findsOneWidget);

    await tester.pumpWidget(buildMap(tester, offset: 12.75));
    expect(find.svg('tz_12.75.svg.vec'), findsOneWidget);

    await tester.pumpWidget(buildMap(tester, offset: 5.0000000000001));
    expect(find.svg('tz_5.svg.vec'), findsOneWidget);
  });

  testWidgets('locale', (tester) async {
    Intl.defaultLocale = 'sv_SE'; // decimal separator = ","
    addTearDown(() => Intl.defaultLocale = null);

    await tester.pumpWidget(buildMap(tester, offset: 5.75));
    expect(find.svg('tz_5.75.svg.vec'), findsOneWidget);
  });

  testWidgets('map size', (tester) async {
    final customSize = mapSize * 1.25;

    LatLng? pressed;

    await tester.pumpWidget(
      buildMap(
        tester,
        onPressed: (coords) => pressed = coords,
        size: customSize,
      ),
    );

    await tester.tap(find.byType(TimezoneMap));
    expect(pressed, isCloseToLatLng(centerLatLng));

    await tester.tapAt(customSize.topLeft(const Offset(0, 0)));
    expect(pressed, isCloseToLatLng(topLeftLatLng));

    // The expected coordinates are specifically for a 960x480 map. Tolerate
    // small differences when tapping near the edges of a different size map.

    await tester.tapAt(customSize.topRight(const Offset(-1, 0)));
    expect(pressed, isCloseToLatLng(topRightLatLng, 10, LengthUnit.Kilometer));

    await tester.tapAt(customSize.bottomLeft(const Offset(0, -1)));
    expect(
        pressed, isCloseToLatLng(bottomLeftLatLng, 10, LengthUnit.Kilometer));

    await tester.tapAt(customSize.bottomRight(const Offset(-1, -1)));
    expect(
        pressed, isCloseToLatLng(bottomRightLatLng, 10, LengthUnit.Kilometer));
  });

  testWidgets('pre-cache', (tester) async {
    final assetBundle = FakeAssetBundle([
      'packages/timezone_map/assets/map.png',
      'packages/timezone_map/assets/tz_-10.png',
      'packages/timezone_map/assets/tz_0.png',
      'packages/timezone_map/assets/tz_4.5.png',
    ]);

    await tester.runAsync(() async {
      await tester.pumpWidget(DefaultAssetBundle(
        bundle: assetBundle,
        child: const MaterialApp(),
      ));

      final context = tester.element(find.byType(MaterialApp));
      await TimezoneMap.precacheAssets(context);
    });

    expect(
      assetBundle.loadedAssets,
      containsAll([
        'packages/timezone_map/assets/map.png',
        'packages/timezone_map/assets/tz_-10.png',
        'packages/timezone_map/assets/tz_0.png',
        'packages/timezone_map/assets/tz_4.5.png',
      ]),
    );
  });
}

class FakeAssetBundle extends CachingAssetBundle {
  FakeAssetBundle(this._fakeAssets);

  final List<String> _fakeAssets;
  final loadedAssets = <String>[];

  @override
  Future<ByteData> load(String key) async {
    var bytes = Uint8List(0);
    switch (key) {
      case 'AssetManifest.json':
        final fakes = Map.fromEntries(_fakeAssets.map((e) => MapEntry(e, [e])));
        bytes = Uint8List.fromList(jsonEncode(fakes).codeUnits);
        break;
      default:
        if (_fakeAssets.contains(key)) {
          loadedAssets.add(key);
          bytes = File('test/test.png').readAsBytesSync();
        }
        break;
    }
    return ByteData.view(bytes.buffer);
  }
}
