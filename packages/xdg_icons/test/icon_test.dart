import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
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
    when(() => mock.onDefaultThemeChanged).thenAnswer(
      (_) => const Stream.empty(),
    );
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
    when(() => mock.onDefaultThemeChanged).thenAnswer(
      (_) => const Stream.empty(),
    );
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
    when(() => mock.onDefaultThemeChanged).thenAnswer(
      (_) => const Stream.empty(),
    );
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
    when(() => mock.onDefaultThemeChanged).thenAnswer(
      (_) => themeChange.stream,
    );
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

  testWidgets('png file', (tester) async {
    final fileName = path.join(Directory.current.path, 'test', 'red.png');

    final mock = MockXdgIconsPlatform();
    when(() => mock.lookupIcon(name: 'red', size: 16))
        .thenAnswer((_) async => XdgIconData(
              baseScale: 1,
              baseSize: 16,
              fileName: fileName,
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
            child: XdgIcon(
              name: 'red',
              size: 16,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.image(FileImage(File(fileName))), findsOneWidget);
  });

  testWidgets('png data', (tester) async {
    final fileName = path.join(Directory.current.path, 'test', 'red.png');
    final bytes = File(fileName).readAsBytesSync();

    final mock = MockXdgIconsPlatform();
    when(() => mock.lookupIcon(name: 'red', size: 16))
        .thenAnswer((_) async => XdgIconData(
              baseScale: 1,
              baseSize: 16,
              fileName: '/gtk/resources/red.png',
              data: bytes,
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
            child: XdgIcon(
              name: 'red',
              size: 16,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final widget = tester.widget<Image>(find.byType(Image));
    expect(widget.image,
        isA<MemoryImage>().having((p) => p.bytes, 'bytes', bytes));
  });

  testWidgets('svg file', (tester) async {
    final fileName = path.join(Directory.current.path, 'test', 'blue.svg');

    final mock = MockXdgIconsPlatform();
    when(() => mock.lookupIcon(name: 'blue', size: 16))
        .thenAnswer((_) async => XdgIconData(
              baseScale: 1,
              baseSize: 16,
              fileName: fileName,
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
            child: XdgIcon(
              name: 'blue',
              size: 16,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final widget = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(widget.pictureProvider,
        isA<FilePicture>().having((p) => p.file.path, 'file', fileName));
  });

  testWidgets('svg data', (tester) async {
    final fileName = path.join(Directory.current.path, 'test', 'blue.svg');
    final bytes = File(fileName).readAsBytesSync();

    final mock = MockXdgIconsPlatform();
    when(() => mock.lookupIcon(name: 'blue', size: 16))
        .thenAnswer((_) async => XdgIconData(
              baseScale: 1,
              baseSize: 16,
              fileName: '/gtk/resources/blue.svg',
              data: bytes,
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
            child: XdgIcon(
              name: 'blue',
              size: 16,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final widget = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(widget.pictureProvider,
        isA<MemoryPicture>().having((p) => p.bytes, 'bytes', bytes));
  });
}

class MockXdgIconsPlatform
    with Mock, MockPlatformInterfaceMixin
    implements XdgIconsPlatform {}
