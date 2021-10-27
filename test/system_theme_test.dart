import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform/platform.dart';
import 'package:xdg_icons/xdg_icons.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

import 'data/system_theme.dart';

void main() {
  test('/etc', () {
    XdgIcons.platform = FakePlatform(environment: {});
    XdgIcons.fs = MemoryFileSystem.test();
    writeSystemTheme(XdgIcons.fs, 'Foo', prefix: '/etc');
    expect(XdgIcons.systemTheme, equals('Foo'));
  });

  test('GTK_DATA_PREFIX', () {
    XdgIcons.platform = FakePlatform(environment: {'GTK_DATA_PREFIX': '/opt'});
    XdgIcons.fs = MemoryFileSystem.test();
    writeSystemTheme(XdgIcons.fs, 'Foo', prefix: '/opt');
    expect(XdgIcons.systemTheme, equals('Foo'));
  });

  test('XDG_CONFIG_DIRS', () {
    XdgIcons.platform = FakePlatform(environment: {});
    XdgIcons.fs = MemoryFileSystem.test();
    writeSystemTheme(XdgIcons.fs, 'Foo', prefix: xdg.configDirs.first.path);
    expect(XdgIcons.systemTheme, equals('Foo'));
  });

  test('XDG_CONFIG_HOME', () {
    XdgIcons.platform = FakePlatform(environment: {});
    XdgIcons.fs = MemoryFileSystem.test();
    writeSystemTheme(XdgIcons.fs, 'Foo', prefix: xdg.configHome.path);
    expect(XdgIcons.systemTheme, equals('Foo'));
  });
}
