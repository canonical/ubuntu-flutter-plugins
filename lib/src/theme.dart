import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gsettings/gsettings.dart';
import 'package:ini/ini.dart';
import 'package:path/path.dart' as p;

import 'dir.dart';
import 'icon.dart';
import 'icons.dart';
import 'lookup.dart';

class XdgIconThemeData {
  const XdgIconThemeData({
    required this.name,
    required this.path,
    required this.description,
    this.parents,
    required this.dirs,
    this.scaledDirs,
    this.hidden,
    this.example,
  });

  static Future<XdgIconThemeData> system() async {
    final settings = GSettings('org.gnome.desktop.interface');
    final theme = await settings.get('icon-theme');
    await settings.close();
    return fromName((theme as DBusString?)?.value ?? 'hicolor');
  }

  static Future<XdgIconThemeData> fallback() => fromName('hicolor');

  static Future<XdgIconThemeData> fromName(String name) async {
    for (final searchPath in XdgIcons.searchPaths) {
      final path = p.join(searchPath, name);
      if (await XdgIcons.fs.file(p.join(path, 'index.theme')).exists()) {
        return fromPath(path);
      }
    }
    throw UnsupportedError('Icon theme $name not found');
  }

  static Future<XdgIconThemeData> fromPath(String path) async {
    final file = XdgIcons.fs.file(p.join(path, 'index.theme'));
    if (!await file.exists()) {
      throw UnsupportedError('Icon theme ${file.path} not found');
    }
    final config = Config.fromStrings(await file.readAsLines());

    const section = 'Icon Theme';

    Future<List<XdgIconThemeData>?> readThemes(String key) async {
      final names = config
          .get(section, key)
          ?.split(',')
          .where((name) => name.trim().isNotEmpty);
      if (names == null) return null;
      final themes = <XdgIconThemeData>[];
      for (final name in names) {
        themes.add(await XdgIconThemeData.fromName(name.trim()));
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

    return XdgIconThemeData(
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
  final List<XdgIconThemeData>? parents;
  final List<XdgIconDir> dirs;
  final List<XdgIconDir>? scaledDirs;
  final bool? hidden;
  final String? example;

  Future<XdgIconData?> findIcon(String name, int size, int scale) async {
    return findIconHelper(name, size, scale, this) ??
        findIconHelper(name, size, scale, await fallback()) ??
        lookupFallbackIcon(name);
  }

  @override
  String toString() =>
      'XdgIconTheme(name: $name, description: $description, parents: $parents, dirs: $dirs, scaledDirs: $scaledDirs, hidden: $hidden, example: $example)';
}

class XdgIconTheme extends InheritedTheme {
  const XdgIconTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  final XdgIconThemeData data;

  static XdgIconThemeData? of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<XdgIconTheme>();
    return theme?.data;
  }

  @override
  bool updateShouldNotify(XdgIconTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return XdgIconTheme(data: data, child: child);
  }
}
