import 'dart:io';

import 'package:flutter/material.dart';

import 'data.dart';
import 'theme.dart';

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
