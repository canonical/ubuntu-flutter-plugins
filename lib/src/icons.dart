import 'dart:io';

import 'package:path/path.dart' as p;

class XdgIcons {
  static List<String>? _extensions;
  static List<String>? _searchPaths;

  static const List<String> defaultExtensions = ['png', 'svg', 'xpm'];

  static List<String> get extensions => _extensions ??= defaultExtensions;
  static set extensions(List<String> extensions) => _extensions = extensions;

  static List<String> get defaultSearchPaths {
    return [
      p.join(Platform.environment['HOME'] ?? '', '.icons'),
      ...?Platform.environment['XDG_DATA_DIRS']
          ?.split(':')
          .map((dir) => p.join(dir + 'icons'))
          .where((dir) => Directory(dir).existsSync())
          .toList(),
      '/usr/share/pixmaps'
    ];
  }

  static List<String> get searchPaths => _searchPaths ??= defaultSearchPaths;
  static set searchPaths(List<String> paths) => _searchPaths = paths;
}
