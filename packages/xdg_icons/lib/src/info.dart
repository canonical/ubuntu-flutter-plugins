import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

enum XdgIconType { fixed, scalable, threshold, fallback }

@immutable
class XdgIconInfo {
  const XdgIconInfo(
    this.path, {
    this.type,
    this.size,
    this.scale,
    this.context,
  });

  final String path;
  final XdgIconType? type;
  final int? size;
  final int? scale;
  final String? context;

  @override
  int get hashCode => Object.hash(path, type, size, scale, context);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is XdgIconInfo &&
        other.path == path &&
        other.type == type &&
        other.size == size &&
        other.scale == scale &&
        other.context == context;
  }

  @override
  String toString() =>
      'XdgIconInfo(path: $path, type: $type, size: $size, scale: $scale, context: $context)';
}

@immutable
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

  final String name;
  final String path;
  final String description;
  final List<XdgIconThemeInfo>? parents;
  final List<XdgIconDirInfo> dirs;
  final List<XdgIconDirInfo>? scaledDirs;
  final bool? hidden;
  final String? example;

  @override
  int get hashCode {
    return Object.hash(
      name,
      path,
      description,
      parents != null ? Object.hashAll(parents!) : null,
      Object.hashAll(dirs),
      scaledDirs != null ? Object.hashAll(scaledDirs!) : null,
      hidden,
      example,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const ListEquality().equals;
    return other is XdgIconThemeInfo &&
        name == other.name &&
        path == other.path &&
        description == other.description &&
        listEquals(parents, other.parents) &&
        listEquals(dirs, other.dirs) &&
        listEquals(scaledDirs, other.scaledDirs) &&
        hidden == other.hidden &&
        example == other.example;
  }

  @override
  String toString() =>
      'XdgIconThemeInfo(name: $name, path: $path, description: $description, parents: $parents, dirs: $dirs, scaledDirs: $scaledDirs, hidden: $hidden, example: $example)';
}

@immutable
class XdgIconDirInfo {
  const XdgIconDirInfo({
    required this.name,
    required this.size,
    int? scale,
    this.context,
    XdgIconType? type,
    int? maxSize,
    int? minSize,
    int? threshold,
  })  : scale = scale ?? (type != XdgIconType.scalable ? 1 : null),
        type = type ?? XdgIconType.threshold,
        maxSize = maxSize ?? size,
        minSize = minSize ?? size,
        threshold = threshold ?? 2;

  final String name;
  final int size;
  final int? scale;
  final String? context;
  final XdgIconType type;
  final int maxSize;
  final int minSize;
  final int threshold;

  @override
  int get hashCode {
    return Object.hash(
      name,
      size,
      scale,
      context,
      type,
      maxSize,
      minSize,
      threshold,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is XdgIconDirInfo &&
        name == other.name &&
        size == other.size &&
        scale == other.scale &&
        context == other.context &&
        type == other.type &&
        maxSize == other.maxSize &&
        minSize == other.minSize &&
        threshold == other.threshold;
  }

  @override
  String toString() =>
      'XdgIconDirInfo(name: $name, size: $size, scale: $scale, context: $context, type: $type, maxSize: $maxSize, minSize: $minSize, threshold: $threshold)';
}
