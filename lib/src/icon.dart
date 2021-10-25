enum XdgIconType { fixed, scalable, threshold, fallback }

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
  String toString() =>
      'XdgIcon(path: $path, type: $type, size: $size, scale: $scale, context: $context)';
}
