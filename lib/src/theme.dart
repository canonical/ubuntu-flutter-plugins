import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:gsettings/gsettings.dart';
import 'package:ini/ini.dart';

import 'directory.dart';
import 'icon.dart';
import 'icons.dart';

class XdgIconTheme {
  const XdgIconTheme({
    required this.name,
    required this.description,
    this.parents,
    required this.directories,
    this.scaledDirectories,
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
    for (final path in XdgIcons.searchPaths) {
      if (await File('$path/$name/index.theme').exists()) {
        return fromPath('$path/$name');
      }
    }
    throw UnsupportedError('Icon theme $name not found');
  }

  static Future<XdgIconTheme> fromPath(String path) async {
    final file = File('$path/index.theme');
    if (!await file.exists()) {
      throw UnsupportedError('Icon theme $path not found');
    }
    return fromConfig(Config.fromStrings(await file.readAsLines()));
  }

  static Future<XdgIconTheme> fromConfig(Config config) async {
    const section = 'Icon Theme';

    Future<List<XdgIconTheme>?> readThemes(String key) async {
      final names = config
          .get(section, key)
          ?.split(',')
          .where((name) => name.trim().isNotEmpty);
      if (names == null) return null;
      final themes = <XdgIconTheme>[];
      for (final theme in names) {
        themes.add(await XdgIconTheme.fromName(theme.trim()));
      }
      return themes;
    }

    List<XdgIconDirectory>? readDirectories(String key) {
      final directories = config
          .get(section, key)
          ?.split(',')
          .where((dir) => dir.trim().isNotEmpty);
      return directories
          ?.map(
              (section) => XdgIconDirectory.fromConfig(config, section.trim()))
          .toList();
    }

    return XdgIconTheme(
      name: config.get(section, 'Name')!,
      description: config.get(section, 'Comment')!,
      parents: await readThemes('Inherits'),
      directories: readDirectories('Directories')!,
      scaledDirectories: readDirectories('ScaledDirectories'),
      hidden: config.get(section, 'Hidden')?.toLowerCase() == 'true',
      example: config.get(section, 'Example'),
    );
  }

  /// Short name of the icon theme, used in e.g. lists when selecting themes.
  final String name;

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
  final List<XdgIconDirectory> directories;

  /// Additional list of subdirectories for this theme, in addition to the ones
  /// in [directories]. These directories should only be read by implementations
  /// supporting scaled directories and was added to keep compatibility with old
  /// implementations that don't support these.
  final List<XdgIconDirectory>? scaledDirectories;

  /// Whether to hide the theme in a theme selection user interface. This is
  /// used for things such as fallback-themes that are not supposed to be
  /// visible to the user.
  final bool? hidden;

  /// The name of an icon that should be used as an example of how this theme
  /// looks.
  final String? example;

  Future<XdgIcon?> findIcon(String name, int size, int scale) async {
    return findIconHelper(name, size, scale, this) ??
        findIconHelper(name, size, scale, await fromName('hicolor')) ??
        lookupFallbackIcon(name);
  }

  XdgIcon? findIconHelper(
      String name, int size, int scale, XdgIconTheme theme) {
    final filename = lookupIcon(name, size, scale);
    if (filename != null) {
      return filename;
    }

    for (final parent in theme.parents ?? []) {
      final filename = findIconHelper(name, size, scale, parent);
      if (filename != null) {
        return filename;
      }
    }
    return null;
  }

  XdgIcon? lookupIcon(String icon, int size, int scale) {
    for (final subdir in directories) {
      for (final directory in XdgIcons.searchPaths) {
        for (final ext in XdgIcons.extensions) {
          if (subdir.matchesSize(size, scale)) {
            final filename = '$directory/$name/${subdir.name}/$icon.$ext';
            if (File(filename).existsSync()) {
              return XdgIcon(
                filename,
                type: subdir.type,
                size: size,
                scale: scale,
              );
            }
          }
        }
      }
    }

    XdgIcon? closestIcon;
    var minimalSize = (1 << 63) - 1;
    for (final subdir in directories) {
      for (final directory in XdgIcons.searchPaths) {
        for (final ext in XdgIcons.extensions) {
          final filename = '$directory/$name/$subdir/$icon.$ext';
          if (File(filename).existsSync() &&
              subdir.sizeDistance(size, scale) < minimalSize) {
            closestIcon = XdgIcon(
              filename,
              type: subdir.type,
              size: size,
              scale: scale,
            );
            minimalSize = subdir.sizeDistance(size, scale);
          }
        }
      }
    }
    return closestIcon;
  }

  static XdgIcon? lookupFallbackIcon(String icon) {
    for (final path in XdgIcons.searchPaths) {
      for (final ext in XdgIcons.extensions) {
        if (File('$path/$icon.$ext').existsSync()) {
          return XdgIcon('$path/$icon.$ext');
        }
      }
    }
    return null;
  }

  @override
  String toString() =>
      'XdgIconTheme(name: $name, description: $description, parents: $parents, directories: $directories, scaledDirectories: $scaledDirectories, hidden: $hidden, example: $example)';
}
