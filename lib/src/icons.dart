import 'package:dbus/dbus.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:gsettings/gsettings.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';

class XdgIcons {
  static String? _systemTheme;
  static List<String>? _extensions;
  static List<String>? _searchPaths;

  static Future<void> init() async {
    // ### TODO:
    // - icon size & scale
    // - desktop environment
    final settings = GSettings('org.gnome.desktop.interface');
    final theme = await settings.get('icon-theme');
    _systemTheme = (theme as DBusString?)?.value ?? 'hicolor';
    await settings.close();
  }

  static int defaultSize = 16;
  static int defaultScale = 1;

  static String get systemTheme {
    assert(_systemTheme != null, 'Call XdgIcons.init()');
    return _systemTheme!;
  }

  static const List<String> defaultExtensions = ['png', 'svg', 'xpm'];

  static List<String> get extensions => _extensions ??= defaultExtensions;
  static set extensions(List<String> extensions) => _extensions = extensions;

  static List<String> get defaultSearchPaths {
    return [
      p.join(platform.environment['HOME'] ?? '', '.icons'),
      ...?platform.environment['XDG_DATA_DIRS']
          ?.split(':')
          .map((dir) => p.join(dir, 'icons'))
          .where((dir) => fs.directory(dir).existsSync())
          .toList(),
      '/usr/share/pixmaps'
    ];
  }

  static List<String> get searchPaths => _searchPaths ??= defaultSearchPaths;
  static set searchPaths(List<String> paths) => _searchPaths = paths;

  @internal
  static FileSystem fs = const LocalFileSystem();

  @internal
  static Platform platform = const LocalPlatform();
}
