import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:xdg_icons/src/data.dart';
import 'package:xdg_icons/src/platform_interface.dart';
import 'package:xdg_icons/xdg_icons.dart';

void main() {
  testWidgets('name and size', (tester) async {
    final mock = MockXdgIconsPlatform();
    when(() => mock.lookupIcon(name: 'foo', size: 24))
        .thenAnswer((_) async => const XdgIconData(
              baseScale: 1,
              baseSize: 42,
              fileName: '/path/to/foo.svg',
              isSymbolic: false,
            ));
    when(() => mock.onDefaultThemeChanged)
        .thenAnswer((_) => const Stream<dynamic>.empty());
    XdgIconsPlatform.instance = mock;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: XdgIcon(
              name: 'foo',
              size: 24,
            ),
          ),
        ),
      ),
    );

    expect(
      tester.state<XdgIconState>(find.byType(XdgIcon)).icon,
      const XdgIconData(
        baseScale: 1,
        baseSize: 42,
        fileName: '/path/to/foo.svg',
        isSymbolic: false,
      ),
    );
  });

  testWidgets('scale and theme', (tester) async {
    final mock = MockXdgIconsPlatform();
    when(() => mock.lookupIcon(name: 'foo', size: 24, scale: 2, theme: 'bar'))
        .thenAnswer((_) async => const XdgIconData(
              baseScale: 2,
              baseSize: 42,
              fileName: '/path/to/bar/foo.svg',
              isSymbolic: false,
            ));
    when(() => mock.onDefaultThemeChanged)
        .thenAnswer((_) => const Stream<dynamic>.empty());
    XdgIconsPlatform.instance = mock;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: XdgIcon(
              name: 'foo',
              size: 24,
              scale: 2,
              theme: 'bar',
            ),
          ),
        ),
      ),
    );

    expect(
      tester.state<XdgIconState>(find.byType(XdgIcon)).icon,
      const XdgIconData(
        baseScale: 2,
        baseSize: 42,
        fileName: '/path/to/bar/foo.svg',
        isSymbolic: false,
      ),
    );
  });

  testWidgets('rebuild', (tester) async {
    final mock = MockXdgIconsPlatform();
    when(() => mock.lookupIcon(
          name: any(named: 'name'),
          size: any(named: 'size'),
          scale: any(named: 'scale'),
          theme: any(named: 'theme'),
        )).thenAnswer((i) async => XdgIconData(
          baseScale: i.namedArguments[#scale] as int,
          baseSize: i.namedArguments[#size] as int,
          fileName:
              '/path/to/${i.namedArguments[#theme]}/${i.namedArguments[#name]}.svg',
          isSymbolic: false,
        ));
    when(() => mock.onDefaultThemeChanged)
        .thenAnswer((_) => const Stream<dynamic>.empty());
    XdgIconsPlatform.instance = mock;

    // first build
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: XdgIcon(
              name: 'foo',
              size: 24,
              scale: 2,
              theme: 'bar',
            ),
          ),
        ),
      ),
    );

    expect(
      tester.state<XdgIconState>(find.byType(XdgIcon)).icon,
      const XdgIconData(
        baseScale: 2,
        baseSize: 24,
        fileName: '/path/to/bar/foo.svg',
        isSymbolic: false,
      ),
    );

    // name
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: XdgIcon(
              name: 'baz',
              size: 24,
              scale: 2,
              theme: 'bar',
            ),
          ),
        ),
      ),
    );

    expect(
      tester.state<XdgIconState>(find.byType(XdgIcon)).icon,
      const XdgIconData(
        baseScale: 2,
        baseSize: 24,
        fileName: '/path/to/bar/baz.svg',
        isSymbolic: false,
      ),
    );

    // size
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: XdgIcon(
              name: 'baz',
              size: 48,
              scale: 2,
              theme: 'bar',
            ),
          ),
        ),
      ),
    );

    expect(
      tester.state<XdgIconState>(find.byType(XdgIcon)).icon,
      const XdgIconData(
        baseScale: 2,
        baseSize: 48,
        fileName: '/path/to/bar/baz.svg',
        isSymbolic: false,
      ),
    );

    // scale
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: XdgIcon(
              name: 'baz',
              size: 48,
              scale: 4,
              theme: 'bar',
            ),
          ),
        ),
      ),
    );

    expect(
      tester.state<XdgIconState>(find.byType(XdgIcon)).icon,
      const XdgIconData(
        baseScale: 4,
        baseSize: 48,
        fileName: '/path/to/bar/baz.svg',
        isSymbolic: false,
      ),
    );

    // theme
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: XdgIcon(
              name: 'baz',
              size: 48,
              scale: 4,
              theme: 'qux',
            ),
          ),
        ),
      ),
    );

    expect(
      tester.state<XdgIconState>(find.byType(XdgIcon)).icon,
      const XdgIconData(
        baseScale: 4,
        baseSize: 48,
        fileName: '/path/to/qux/baz.svg',
        isSymbolic: false,
      ),
    );
  });

  testWidgets('theme change', (tester) async {
    final mock = MockXdgIconsPlatform();
    when(() => mock.lookupIcon(name: 'foo', size: 24))
        .thenAnswer((_) async => const XdgIconData(
              baseScale: 1,
              baseSize: 42,
              fileName: '/path/to/foo.svg',
              isSymbolic: false,
            ));
    final themeChange = StreamController<dynamic>.broadcast(sync: true);
    when(() => mock.onDefaultThemeChanged)
        .thenAnswer((_) => themeChange.stream);
    XdgIconsPlatform.instance = mock;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: XdgIcon(
              name: 'foo',
              size: 24,
            ),
          ),
        ),
      ),
    );

    verify(() => mock.lookupIcon(name: 'foo', size: 24)).called(1);
    themeChange.add(null);
    verify(() => mock.lookupIcon(name: 'foo', size: 24)).called(1);
  });
}

class MockXdgIconsPlatform
    with Mock, MockPlatformInterfaceMixin
    implements XdgIconsPlatform {}
