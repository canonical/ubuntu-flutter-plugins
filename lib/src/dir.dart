import 'package:collection/collection.dart';
import 'package:ini/ini.dart';
import 'package:meta/meta.dart';

import 'icon.dart';

@immutable
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
    return other is XdgIconDir &&
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
      'XdgIconDir(name: $name, size: $size, scale: $scale, context: $context, type: $type, maxSize: $maxSize, minSize: $minSize, threshold: $threshold)';
}
