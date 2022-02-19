import 'package:path/path.dart' as p;

import 'config.dart';
import 'io.dart';
import 'info.dart';
import 'themes.dart';

class XdgIcons {
  XdgIcons(this.theme);

  final XdgIconThemeInfo theme;

  Future<XdgIconInfo?> lookup(String name, int size, int scale) async {
    final system = await XdgIconThemes.system();
    return theme.lookupIconHelper(name, size, scale) ??
        (system != theme ? system.lookupIconHelper(name, size, scale) : null) ??
        _lookupFallbackIcon(name);
  }
}

XdgIconInfo? _lookupFallbackIcon(String icon) {
  for (final path in XdgIconConfig.searchPaths) {
    for (final ext in XdgIconConfig.extensions) {
      if (XdgIconsIO.file('$path/$icon.$ext').existsSync()) {
        return XdgIconInfo('$path/$icon.$ext', type: XdgIconType.fallback);
      }
    }
  }
  return null;
}

extension _XdgIconThemeLookup on XdgIconThemeInfo {
  XdgIconInfo? lookupIconHelper(String name, int size, int scale) {
    final filename = lookupIcon(name, size, scale);
    if (filename != null) {
      return filename;
    }

    for (final parent in parents ?? []) {
      final filename = parent.lookupIconHelper(name, size, scale);
      if (filename != null) {
        return filename;
      }
    }
    return null;
  }

  XdgIconInfo? lookupIcon(String icon, int size, int scale) {
    final basename = p.basename(path);
    for (final dir in dirs) {
      if (!dir.matchesSize(size, scale)) continue;

      for (final path in XdgIconConfig.searchPaths) {
        for (final ext in XdgIconConfig.extensions) {
          final filename = '$path/$basename/${dir.name}/$icon.$ext';
          if (XdgIconsIO.file(filename).existsSync()) {
            return XdgIconInfo(
              filename,
              type: dir.type,
              size: size,
              scale: dir.scale,
              context: dir.context,
            );
          }
        }
      }
    }

    XdgIconInfo? closestIcon;
    var minimalSize = (1 << 63) - 1;
    for (final dir in dirs) {
      if (dir.sizeDistance(size, scale) >= minimalSize) continue;

      for (final path in XdgIconConfig.searchPaths) {
        for (final ext in XdgIconConfig.extensions) {
          final filename = '$path/$basename/${dir.name}/$icon.$ext';
          if (XdgIconsIO.file(filename).existsSync()) {
            closestIcon = XdgIconInfo(
              filename,
              type: dir.type,
              size: size,
              scale: dir.scale,
              context: dir.context,
            );
            minimalSize = dir.sizeDistance(size, scale);
          }
        }
      }
    }
    return closestIcon;
  }
}

extension _XdgIconDirLookup on XdgIconDirInfo {
  bool matchesSize(int size, int scale) {
    switch (type) {
      case XdgIconType.fixed:
        return this.scale == scale && this.size == size;

      case XdgIconType.scalable:
        return minSize <= size && size <= maxSize;

      case XdgIconType.threshold:
        return this.scale == scale &&
            this.size - threshold <= size &&
            size <= this.size + threshold;

      case XdgIconType.fallback:
        throw ArgumentError('Fallback icons do not have a size');
    }
  }

  int sizeDistance(int size, int scale) {
    switch (type) {
      case XdgIconType.fixed:
        return (this.size * this.scale! - size * scale).abs();

      case XdgIconType.scalable:
        if (size * scale < minSize) {
          return minSize - size * scale;
        }
        if (size * scale > maxSize) {
          return size * scale - maxSize;
        }
        return 0;

      case XdgIconType.threshold:
        if (size * scale < (this.size - threshold) * this.scale!) {
          return minSize * this.scale! - size * scale;
        }
        if (size * size > (this.size + threshold) * this.scale!) {
          return size * size - maxSize * this.scale!;
        }
        return 0;

      case XdgIconType.fallback:
        throw ArgumentError('Fallback icons do not have a size');
    }
  }
}
