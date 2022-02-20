import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform/platform.dart';
import 'package:xdg_icons/xdg_icons.dart';
import 'package:xdg_icons/src/io.dart';

import 'data/birch_theme.dart';
import 'data/hicolor_theme.dart';
import 'data/system_theme.dart';
import 'data/wooden_theme.dart';

void main() {
  setUpAll(() {
    XdgIconsIO.platform = FakePlatform(environment: {
      'HOME': '/home/user',
      'XDG_DATA_DIRS': '/usr/local/share:/usr/share',
    });
  });

  setUp(() {
    XdgIconsIO.fs = MemoryFileSystem.test();
    writeSystemTheme(XdgIconsIO.fs, 'hicolor');
    writeHicolorTheme(XdgIconsIO.fs, '/usr/share/icons/hicolor');
  });

  test('wooden', () async {
    writeWoodenTheme(XdgIconsIO.fs, '/usr/share/icons/wooden');
    writeHicolorTheme(XdgIconsIO.fs, '/usr/share/icons/hicolor');

    final theme = await XdgIconThemes.lookup('wooden');
    expect(theme, isNotNull);
    expect(theme!.name, 'Wooden');
    expect(theme.description, 'Icon theme with a wooden look');

    for (final sz in [32, 48]) {
      final f1 = await XdgIcons(theme).lookup('firefox', sz, 1);
      expect(f1, isNotNull);
      expect(f1!.path, '/usr/share/icons/wooden/${sz}x$sz/apps/firefox.png');
      expect(f1.size, sz);
      expect(f1.scale, 1);
      expect(f1.type, XdgIconType.fixed);
      expect(f1.context, 'Applications');

      final f2 = await XdgIcons(theme).lookup('firefox', sz, 2);
      expect(f2, isNotNull);
      expect(f2!.path, '/usr/share/icons/wooden/${sz}x$sz@2/apps/firefox.png');
      expect(f2.size, sz);
      expect(f2.scale, 2);
      expect(f2.type, XdgIconType.fixed);
      expect(f2.context, 'Applications');
    }
  });

  test('birch', () async {
    writeBirchTheme(XdgIconsIO.fs, '/home/user/.icons/birch');
    writeWoodenTheme(XdgIconsIO.fs, '/usr/share/icons/wooden');

    final theme = await XdgIconThemes.lookup('birch');
    expect(theme, isNotNull);
    expect(theme!.name, 'Birch');
    expect(theme.description, 'Icon theme with a birch look');

    for (final scale in [1, 2]) {
      final fs = await XdgIcons(theme).lookup('firefox', 128, scale);
      expect(fs, isNotNull);
      expect(fs!.path, '/home/user/.icons/birch/scalable/apps/firefox.svg');
      expect(fs.size, 128);
      expect(fs.scale, isNull);
      expect(fs.type, XdgIconType.scalable);
      expect(fs.context, 'Applications');
    }
  });
}
