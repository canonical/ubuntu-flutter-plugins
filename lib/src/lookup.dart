import 'package:path/path.dart' as p;

import 'data.dart';
import 'dir.dart';
import 'icons.dart';
import 'theme.dart';

XdgIconData? lookupFallbackIcon(String icon) {
  for (final path in XdgIcons.searchPaths) {
    for (final ext in XdgIcons.extensions) {
      if (XdgIcons.fs.file('$path/$icon.$ext').existsSync()) {
        return XdgIconData('$path/$icon.$ext', type: XdgIconType.fallback);
      }
    }
  }
  return null;
}

extension XdgIconThemeLookup on XdgIconTheme {
  XdgIconData? findIconHelper(
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

  XdgIconData? lookupIcon(String icon, int size, int scale) {
    final basename = p.basename(path);
    for (final dir in dirs) {
      if (!dir.matchesSize(size, scale)) continue;

      for (final path in XdgIcons.searchPaths) {
        for (final ext in XdgIcons.extensions) {
          final filename = '$path/$basename/${dir.name}/$icon.$ext';
          if (XdgIcons.fs.file(filename).existsSync()) {
            return XdgIconData(
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

    XdgIconData? closestIcon;
    var minimalSize = (1 << 63) - 1;
    for (final dir in dirs) {
      if (dir.sizeDistance(size, scale) >= minimalSize) continue;

      for (final path in XdgIcons.searchPaths) {
        for (final ext in XdgIcons.extensions) {
          final filename = '$path/$basename/$dir/$icon.$ext';
          if (XdgIcons.fs.file(filename).existsSync()) {
            closestIcon = XdgIconData(
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

extension XdgIconDirLookup on XdgIconDir {
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
