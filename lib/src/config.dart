import 'package:ini/ini.dart';
import 'package:path/path.dart' as p;
import 'package:xdg_directories/xdg_directories.dart' as xdg;

import 'io.dart';

class XdgIconConfig {
  static bool _initialized = false;
  static String? _systemTheme;
  static int? _defaultSize;
  static int? _defaultScale;
  static List<String>? _extensions;
  static List<String>? _searchPaths;

  static int get defaultSize {
    _ensureInitialized();
    return _defaultSize ?? 16;
  }

  static set defaultSize(int size) => _defaultSize = size;

  static int get defaultScale {
    _ensureInitialized();
    return _defaultScale ?? 1;
  }

  static set defaultScale(int scale) => _defaultScale = scale;

  static String get systemTheme {
    _ensureInitialized();
    assert(_systemTheme != null, 'ERROR: failed to resolve system icon theme');
    return _systemTheme!;
  }

  static set systemTheme(String theme) => _systemTheme = theme;

  static List<String> get extensions =>
      _extensions ?? const ['png', 'svg', 'xpm'];
  static set extensions(List<String> extensions) => _extensions = extensions;

  static List<String> get searchPaths {
    _searchPaths ??= [
      p.join(XdgIconsIO.environment['HOME'] ?? '', '.icons'),
      ...?XdgIconsIO.environment['XDG_DATA_DIRS']
          ?.split(':')
          .map((dir) => p.join(dir, 'icons'))
          .where((dir) => XdgIconsIO.directory(dir).existsSync())
          .toList(),
      '/usr/share/pixmaps'
    ];
    return _searchPaths!;
  }

  static void _ensureInitialized() {
    if (_initialized) return;
    // ### TODO: detect desktop environment
    final configPaths = [
      xdg.configHome.path,
      ...xdg.configDirs.map((dir) => dir.path),
      XdgIconsIO.environment['GTK_DATA_PREFIX'] ?? '/etc',
    ];
    for (final path in configPaths) {
      final file = XdgIconsIO.file(p.join(path, 'gtk-3.0', 'settings.ini'));
      if (file.existsSync()) {
        final ini = Config.fromStrings(file.readAsLinesSync());
        _systemTheme ??= ini.get('Settings', 'gtk-icon-theme-name');
      }
      if (_systemTheme != null && _defaultSize != null) break;
    }
    _defaultScale ??=
        double.tryParse(XdgIconsIO.environment['GDK_SCALE'] ?? '')?.round() ??
            1;
    _initialized = true;
  }
}
