import 'package:path/path.dart' as p;

import 'directory.dart';
import 'icon.dart';
import 'icons.dart';
import 'theme.dart';

XdgIcon? lookupFallbackIcon(String icon) {
  for (final path in XdgIcons.searchPaths) {
    for (final ext in XdgIcons.extensions) {
      if (XdgIcons.fs.file('$path/$icon.$ext').existsSync()) {
        return XdgIcon('$path/$icon.$ext', type: XdgIconType.fallback);
      }
    }
  }
  return null;
}

extension XdgIconThemeLookup on XdgIconTheme {
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
    final basename = p.basename(path);
    for (final directory in directories) {
      if (!directory.matchesSize(size, scale)) continue;

      for (final path in XdgIcons.searchPaths) {
        for (final ext in XdgIcons.extensions) {
          final filename = '$path/$basename/${directory.name}/$icon.$ext';
          if (XdgIcons.fs.file(filename).existsSync()) {
            return XdgIcon(
              filename,
              type: directory.type,
              size: size,
              scale: directory.scale,
              context: directory.context,
            );
          }
        }
      }
    }

    XdgIcon? closestIcon;
    var minimalSize = (1 << 63) - 1;
    for (final directory in directories) {
      if (directory.sizeDistance(size, scale) >= minimalSize) continue;

      for (final path in XdgIcons.searchPaths) {
        for (final ext in XdgIcons.extensions) {
          final filename = '$path/$basename/$directory/$icon.$ext';
          if (XdgIcons.fs.file(filename).existsSync()) {
            closestIcon = XdgIcon(
              filename,
              type: directory.type,
              size: size,
              scale: directory.scale,
              context: directory.context,
            );
            minimalSize = directory.sizeDistance(size, scale);
          }
        }
      }
    }
    return closestIcon;
  }
}

extension XdgIconDirectoryLookup on XdgIconDirectory {
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
