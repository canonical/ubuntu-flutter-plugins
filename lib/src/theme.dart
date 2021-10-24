import 'package:dbus/dbus.dart';
import 'package:gsettings/gsettings.dart';
import 'package:ini/ini.dart';
import 'package:path/path.dart' as p;

import 'dir.dart';
import 'icon.dart';
import 'icons.dart';
import 'lookup.dart';

class XdgIconTheme {
  const XdgIconTheme({
    required this.name,
    required this.path,
    required this.description,
    this.parents,
    required this.dirs,
    this.scaledDirs,
    this.hidden,
    this.example,
  });

  static Future<XdgIconTheme> system() async {
    final settings = GSettings('org.gnome.desktop.interface');
    final theme = await settings.get('icon-theme');
    await settings.close();
    return fromName((theme as DBusString?)?.value ?? 'hicolor');
  }

  static Future<XdgIconTheme> fromName(String name) async {
    for (final searchPath in XdgIcons.searchPaths) {
      final path = p.join(searchPath, name);
      if (await XdgIcons.fs.file(p.join(path, 'index.theme')).exists()) {
        return fromPath(path);
      }
    }
    throw UnsupportedError('Icon theme $name not found');
  }

  static Future<XdgIconTheme> fromPath(String path) async {
    final file = XdgIcons.fs.file(p.join(path, 'index.theme'));
    if (!await file.exists()) {
      throw UnsupportedError('Icon theme ${file.path} not found');
    }
    final config = Config.fromStrings(await file.readAsLines());

    const section = 'Icon Theme';

    Future<List<XdgIconTheme>?> readThemes(String key) async {
      final names = config
          .get(section, key)
          ?.split(',')
          .where((name) => name.trim().isNotEmpty);
      if (names == null) return null;
      final themes = <XdgIconTheme>[];
      for (final name in names) {
        themes.add(await XdgIconTheme.fromName(name.trim()));
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

    return XdgIconTheme(
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

  /// Short name of the icon theme, used in e.g. lists when selecting themes.
  final String name;

  final String path;

  /// Longer string describing the theme.
  final String description;

  /// The name of the theme that this theme inherits from. If an icon name is
  /// not found in the current theme, it is searched for in the inherited theme
  /// (and recursively in all the inherited themes).
  ///
  /// If no theme is specified implementations are required to add the "hicolor"
  /// theme to the inheritance tree. An implementation may optionally add other
  /// default themes in between the last specified theme and the hicolor theme.
  final List<XdgIconTheme>? parents;

  /// List of subdirectories for this theme. For every subdirectory there must
  /// be a section in the `index.theme` file describing that directory.
  final List<XdgIconDir> dirs;

  /// Additional list of subdirectories for this theme, in addition to the ones
  /// in [dirs]. These directories should only be read by implementations
  /// supporting scaled directories and was added to keep compatibility with old
  /// implementations that don't support these.
  final List<XdgIconDir>? scaledDirs;

  /// Whether to hide the theme in a theme selection user interface. This is
  /// used for things such as fallback-themes that are not supposed to be
  /// visible to the user.
  final bool? hidden;

  /// The name of an icon that should be used as an example of how this theme
  /// looks.
  final String? example;

  Future<XdgIconData?> findIcon(String name, int size, int scale) async {
    return findIconHelper(name, size, scale, this) ??
        findIconHelper(name, size, scale, await fromName('hicolor')) ??
        lookupFallbackIcon(name);
  }

  @override
  String toString() =>
      'XdgIconTheme(name: $name, description: $description, parents: $parents, dirs: $dirs, scaledDirs: $scaledDirs, hidden: $hidden, example: $example)';
}
