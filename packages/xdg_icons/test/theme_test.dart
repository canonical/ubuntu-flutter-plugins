import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:xdg_icons/src/data.dart';
import 'package:xdg_icons/src/platform_interface.dart';
import 'package:xdg_icons/xdg_icons.dart';

void main() {
  testWidgets('theme data', (tester) async {
    final mock = MockXdgIconsPlatform();
    when(() => mock.lookupIcon(name: 'foo', size: 48, scale: 2, theme: 'bar'))
        .thenAnswer((_) async => const XdgIconData(
              baseScale: 2,
              baseSize: 48,
              fileName: '/path/to/foo.svg',
              isSymbolic: false,
            ));
    when(() => mock.lookupIcon(name: 'foo', size: 24, scale: 1, theme: 'bar'))
        .thenAnswer((_) async => const XdgIconData(
              baseScale: 1,
              baseSize: 24,
              fileName: '/path/to/foo.svg',
              isSymbolic: false,
            ));

    when(() => mock.onDefaultThemeChanged).thenAnswer(
      (_) => const Stream.empty(),
    );
    XdgIconsPlatform.instance = mock;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: XdgIconTheme(
              data: XdgIconThemeData(
                size: 48,
                scale: 2,
                theme: 'bar',
              ),
              child: XdgIcon(
                name: 'foo',
              ),
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
        fileName: '/path/to/foo.svg',
        isSymbolic: false,
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: XdgIconTheme(
              data: XdgIconThemeData(
                size: 24,
                scale: 1,
                theme: 'bar',
              ),
              child: XdgIcon(
                name: 'foo',
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.state<XdgIconState>(find.byType(XdgIcon)).icon,
      const XdgIconData(
        baseScale: 1,
        baseSize: 24,
        fileName: '/path/to/foo.svg',
        isSymbolic: false,
      ),
    );
  });

  test('copy with', () {
    const data = XdgIconThemeData(
      size: 48,
      scale: 2,
      theme: 'bar',
    );

    expect(
      data.copyWith(size: 24),
      const XdgIconThemeData(
        size: 24,
        scale: 2,
        theme: 'bar',
      ),
    );

    expect(
      data.copyWith(scale: 1),
      const XdgIconThemeData(
        size: 48,
        scale: 1,
        theme: 'bar',
      ),
    );

    expect(
      data.copyWith(theme: 'baz'),
      const XdgIconThemeData(
        size: 48,
        scale: 2,
        theme: 'baz',
      ),
    );
  });

  test('merge', () {
    const data = XdgIconThemeData(
      size: 48,
      theme: 'bar',
    );
    const other = XdgIconThemeData(
      size: 24,
      scale: 2,
    );

    expect(data.merge(null), data);

    expect(
      data.merge(other),
      const XdgIconThemeData(
        size: 24,
        scale: 2,
        theme: 'bar',
      ),
    );

    expect(
      other.merge(data),
      const XdgIconThemeData(
        size: 48,
        scale: 2,
        theme: 'bar',
      ),
    );
  });

  test('debug fill properties', () {
    final builder = DiagnosticPropertiesBuilder();
    const XdgIconThemeData(
      size: 48,
      scale: 2,
      theme: 'bar',
    ).debugFillProperties(builder);

    final properties =
        builder.properties.map((node) => node.name.toString()).toSet();
    expect(properties, <String>{'theme', 'size', 'scale'});
  });
}

class MockXdgIconsPlatform
    with Mock, MockPlatformInterfaceMixin
    implements XdgIconsPlatform {}
