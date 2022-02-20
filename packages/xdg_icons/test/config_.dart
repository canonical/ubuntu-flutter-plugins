import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform/platform.dart';
import 'package:xdg_icons/xdg_icons.dart';
import 'package:xdg_icons/src/io.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

import 'data/system_theme.dart';

void main() {
  test('/etc', () {
    XdgIconsIO.platform = FakePlatform(environment: {});
    XdgIconsIO.fs = MemoryFileSystem.test();
    writeSystemTheme(XdgIconsIO.fs, 'Foo', prefix: '/etc');
    expect(XdgIconConfig.systemTheme, equals('Foo'));
  });

  test('GTK_DATA_PREFIX', () {
    XdgIconsIO.platform =
        FakePlatform(environment: {'GTK_DATA_PREFIX': '/opt'});
    XdgIconsIO.fs = MemoryFileSystem.test();
    writeSystemTheme(XdgIconsIO.fs, 'Foo', prefix: '/opt');
    expect(XdgIconConfig.systemTheme, equals('Foo'));
  });

  test('XDG_CONFIG_DIRS', () {
    XdgIconsIO.platform = FakePlatform(environment: {});
    XdgIconsIO.fs = MemoryFileSystem.test();
    writeSystemTheme(XdgIconsIO.fs, 'Foo', prefix: xdg.configDirs.first.path);
    expect(XdgIconConfig.systemTheme, equals('Foo'));
  });

  test('XDG_CONFIG_HOME', () {
    XdgIconsIO.platform = FakePlatform(environment: {});
    XdgIconsIO.fs = MemoryFileSystem.test();
    writeSystemTheme(XdgIconsIO.fs, 'Foo', prefix: xdg.configHome.path);
    expect(XdgIconConfig.systemTheme, equals('Foo'));
  });
}
