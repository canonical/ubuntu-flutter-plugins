import 'package:file/memory.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';
import 'package:xdg_icons/xdg_icons.dart';

import 'data/birch_theme.dart';
import 'data/wooden_theme.dart';

void main() {
  setUpAll(() {
    XdgIcons.platform = FakePlatform(environment: {
      'HOME': '/home/user',
      'XDG_DATA_DIRS': '/usr/local/share:/usr/share',
    });
  });

  test('wooden', () async {
    XdgIcons.fs = MemoryFileSystem.test();
    writeWoodenTheme(XdgIcons.fs, '/usr/share/icons/wooden');

    final theme = await XdgIconTheme.fromName('wooden');
    expect(theme.name, 'Wooden');
    expect(theme.description, 'Icon theme with a wooden look');
  });

  test('birch', () async {
    XdgIcons.fs = MemoryFileSystem.test();
    writeBirchTheme(XdgIcons.fs, '/home/user/.icons/birch');
    writeWoodenTheme(XdgIcons.fs, '/usr/share/icons/wooden');

    final theme = await XdgIconTheme.fromName('birch');
    expect(theme.name, 'Birch');
    expect(theme.description, 'Icon theme with a birch look');
  });
}
