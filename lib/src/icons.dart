import 'package:file/file.dart';
import 'package:ini/ini.dart';
import 'package:file/local.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

class XdgIcons {
  static bool _initialized = false;
  static String? _systemTheme;
  static int? _defaultSize;
  static int? _defaultScale;
  static List<String>? _extensions;
  static List<String>? _searchPaths;

  static void init() {
    // ### TODO: detect desktop environment
    final configPaths = [
      xdg.configHome.path,
      ...xdg.configDirs.map((dir) => dir.path),
      platform.environment['GTK_DATA_PREFIX'] ?? '/etc',
    ];
    for (final path in configPaths) {
      final file = fs.file(p.join(path, 'gtk-3.0', 'settings.ini'));
      if (file.existsSync()) {
        final ini = Config.fromStrings(file.readAsLinesSync());
        _systemTheme ??= ini.get('Settings', 'gtk-icon-theme-name');
      }
      if (_systemTheme != null && _defaultSize != null) break;
    }
    _defaultScale ??=
        double.tryParse(platform.environment['GDK_SCALE'] ?? '')?.round() ?? 1;
    _initialized = true;
  }

  static int get defaultSize {
    if (!_initialized) init();
    return _defaultSize ?? 16;
  }

  static int get defaultScale {
    if (!_initialized) init();
    return _defaultScale ?? 1;
  }

  static String get systemTheme {
    if (!_initialized) init();
    assert(_systemTheme != null, 'ERROR: failed to resolve system icon theme');
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
