enum XdgIconType { fixed, scalable, threshold }

class XdgIcon {
  const XdgIcon(
    this.path, {
    this.type,
    this.size,
    this.scale,
  });

  final String path;
  final XdgIconType? type;
  final int? size;
  final int? scale;

  @override
  String toString() =>
      'XdgIcon(path: $path, type: $type, size: $size, scale: $scale)';
}
