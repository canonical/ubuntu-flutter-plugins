import 'package:collection/collection.dart';
import 'package:ini/ini.dart';

import 'icon.dart';

class XdgIconDir {
  const XdgIconDir({
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

  factory XdgIconDir.fromConfig(Config config, String section) {
    final type = config.get(section, 'Type')?.toLowerCase();
    return XdgIconDir(
      name: section,
      size: int.parse(config.get(section, 'Size')!),
      scale: int.tryParse(config.get(section, 'Scale') ?? ''),
      context: config.get(section, 'Context'),
      type: XdgIconType.values.firstWhereOrNull(
        (value) => value.toString().split('.').last.toLowerCase() == type,
      ),
      maxSize: int.tryParse(config.get(section, 'MaxSize') ?? ''),
      minSize: int.tryParse(config.get(section, 'MinSize') ?? ''),
      threshold: int.tryParse(config.get(section, 'Threshold') ?? ''),
    );
  }

  /// The namme of the directory.
  final String name;

  /// Nominal (unscaled) size of the icons in this directory.
  final int size;

  /// Target scale of of the icons in this directory. Defaults to the value 1 if
  /// not present. Any directory with a scale other than 1 should be listed in
  /// the [XdgIconTheme.scaledDirs] list rather than [XdgIconTheme.dirs]
  /// for backwards compatibility.
  final int? scale;

  /// The context the icon is normally used in. This is in detail discussed in
  /// the section called “Context”.
  final String? context;

  /// The type of icon sizes for the icons in this directory. Valid types are
  /// [XdgIconType.fixed], [XdgIconType.scalable] and [XdgIconType.threshold].
  /// The type decides what other keys in the section are used. If not specified,
  /// the default is [XdgIconType.threshold].
  final XdgIconType type;

  /// Specifies the maximum (unscaled) size that the icons in this directory can
  /// be scaled to. Defaults to the value of [size] if not present.
  final int maxSize;

  /// Specifies the minimum (unscaled) size that the icons in this directory can
  /// be scaled to. Defaults to the value of [size] if not present.
  final int minSize;

  /// The icons in this directory can be used if the size differ at most this
  /// much from the desired (unscaled) size. Defaults to 2 if not present.
  final int threshold;

  @override
  String toString() =>
      'XdgIconDir(name: $name, size: $size, scale: $scale, context: $context, type: $type, maxSize: $maxSize, minSize: $minSize, threshold: $threshold)';
}
