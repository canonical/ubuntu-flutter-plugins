import 'package:collection/collection.dart';
import 'package:ini/ini.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'io.dart';
import 'info.dart';

class XdgIconThemes {
  static Future<XdgIconThemeInfo> system() =>
      lookup(XdgIconConfig.systemTheme).then((theme) => theme!);

  static Future<XdgIconThemeInfo?> lookup(String? name) async {
    for (final searchPath in XdgIconConfig.searchPaths) {
      final path = p.join(searchPath, name);
      if (await XdgIconsIO.file(p.join(path, 'index.theme')).exists()) {
        return read(path);
      }
    }
    return null;
  }

  static Future<XdgIconThemeInfo> read(String path) async {
    final file = XdgIconsIO.file(p.join(path, 'index.theme'));
    if (!await file.exists()) {
      throw UnsupportedError('Icon theme ${file.path} not found');
    }
    final config = Config.fromStrings(await file.readAsLines());
    return XdgIconThemeInfo(
      name: config.get('Icon Theme', 'Name')!,
      path: path,
      description: config.get('Icon Theme', 'Comment')!,
      parents: await config.readThemes('Icon Theme', 'Inherits'),
      dirs: config._readDirs('Icon Theme', 'Directories')!,
      scaledDirs: config._readDirs('Icon Theme', 'ScaledDirectories'),
      hidden: config.get('Icon Theme', 'Hidden')?.toLowerCase() == 'true',
      example: config.get('Icon Theme', 'Example'),
    );
  }
}

extension _XdgIconDirConfig on Config {
  Future<List<XdgIconThemeInfo>?> readThemes(String section, String key) async {
    final names =
        get(section, key)?.split(',').where((name) => name.trim().isNotEmpty);
    if (names == null) return null;
    final themes = <XdgIconThemeInfo>[];
    for (final name in names) {
      final theme = await XdgIconThemes.lookup(name.trim());
      if (theme != null) {
        themes.add(theme);
      }
    }
    return themes;
  }

  List<XdgIconDirInfo>? _readDirs(String section, String key) {
    final dirs =
        get(section, key)?.split(',').where((dir) => dir.trim().isNotEmpty);
    return dirs?.map((section) => _readDir(section.trim())).toList();
  }

  XdgIconDirInfo _readDir(String section) {
    final type = get(section, 'Type')?.toLowerCase();
    return XdgIconDirInfo(
      name: section,
      size: int.parse(get(section, 'Size')!),
      scale: int.tryParse(get(section, 'Scale') ?? ''),
      context: get(section, 'Context'),
      type: XdgIconType.values.firstWhereOrNull(
        (value) => value.toString().split('.').last.toLowerCase() == type,
      ),
      maxSize: int.tryParse(get(section, 'MaxSize') ?? ''),
      minSize: int.tryParse(get(section, 'MinSize') ?? ''),
      threshold: int.tryParse(get(section, 'Threshold') ?? ''),
    );
  }
}
