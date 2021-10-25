import 'package:ini/ini.dart';
import 'package:path/path.dart' as p;

import 'dir.dart';
import 'icon.dart';
import 'icons.dart';
import 'lookup.dart';

class XdgIconThemeInfo {
  const XdgIconThemeInfo({
    required this.name,
    required this.path,
    required this.description,
    this.parents,
    required this.dirs,
    this.scaledDirs,
    this.hidden,
    this.example,
  });

  static Future<XdgIconThemeInfo> system() =>
      fromName(XdgIcons.systemTheme).then((theme) => theme!);

  static Future<XdgIconThemeInfo?> fromName(String? name) async {
    for (final searchPath in XdgIcons.searchPaths) {
      final path = p.join(searchPath, name);
      if (await XdgIcons.fs.file(p.join(path, 'index.theme')).exists()) {
        return fromPath(path);
      }
    }
    return null;
  }

  static Future<XdgIconThemeInfo> fromPath(String path) async {
    final file = XdgIcons.fs.file(p.join(path, 'index.theme'));
    if (!await file.exists()) {
      throw UnsupportedError('Icon theme ${file.path} not found');
    }
    final config = Config.fromStrings(await file.readAsLines());

    const section = 'Icon Theme';

    Future<List<XdgIconThemeInfo>?> readThemes(String key) async {
      final names = config
          .get(section, key)
          ?.split(',')
          .where((name) => name.trim().isNotEmpty);
      if (names == null) return null;
      final themes = <XdgIconThemeInfo>[];
      for (final name in names) {
        final theme = await XdgIconThemeInfo.fromName(name.trim());
        if (theme != null) {
          themes.add(theme);
        }
      }
      return themes;
    }

    List<XdgIconDir>? readDirs(String key) {
      final dirs = config
          .get(section, key)
          ?.split(',')
          .where((dir) => dir.trim().isNotEmpty);
      return dirs
          ?.map((section) => XdgIconDir.fromConfig(config, section.trim()))
          .toList();
    }

    return XdgIconThemeInfo(
      name: config.get(section, 'Name')!,
      path: path,
      description: config.get(section, 'Comment')!,
      parents: await readThemes('Inherits'),
      dirs: readDirs('Directories')!,
      scaledDirs: readDirs('ScaledDirectories'),
      hidden: config.get(section, 'Hidden')?.toLowerCase() == 'true',
      example: config.get(section, 'Example'),
    );
  }

  final String name;
  final String path;
  final String description;
  final List<XdgIconThemeInfo>? parents;
  final List<XdgIconDir> dirs;
  final List<XdgIconDir>? scaledDirs;
  final bool? hidden;
  final String? example;

  Future<XdgIconData?> findIcon(String name, int size, int scale) async {
    final system = await XdgIconThemeInfo.system();
    return findIconHelper(name, size, scale, this) ??
        (system != this ? findIconHelper(name, size, scale, system) : null) ??
        lookupFallbackIcon(name);
  }

  @override
  String toString() =>
      'XdgIconTheme(name: $name, path: $path, description: $description, parents: $parents, dirs: $dirs, scaledDirs: $scaledDirs, hidden: $hidden, example: $example)';
}
