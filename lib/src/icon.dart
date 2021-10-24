import 'dart:io';

import 'package:flutter/material.dart';

import 'theme.dart';

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

class XdgIcon extends StatelessWidget {
  XdgIcon({
    Key? key,
    required this.name,
    required this.size,
    required this.scale,
    required this.theme,
  })  : _data = theme.findIcon(name, size, scale),
        super(key: key);

  final String name;
  final int size;
  final int scale;
  final XdgIconTheme theme;

  final Future<XdgIconData?> _data;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _data,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final icon = snapshot.data as XdgIconData?;
        return Image.file(
          File(icon!.path),
          height: size.toDouble(),
          width: size.toDouble(),
        );
      },
    );
  }
}
