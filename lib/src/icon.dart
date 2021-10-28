import 'package:meta/meta.dart';

enum XdgIconType { fixed, scalable, threshold, fallback }

@immutable
class XdgIconData {
  const XdgIconData(
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
    return other is XdgIconData &&
        other.path == path &&
        other.type == type &&
        other.size == size &&
        other.scale == scale &&
        other.context == context;
  }

  @override
  String toString() =>
      'XdgIcon(path: $path, type: $type, size: $size, scale: $scale, context: $context)';
}
