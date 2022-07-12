import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gtk_icon_theme/gtk_icon_theme.dart';

import 'theme.dart';

class XdgIcon extends StatefulWidget {
  const XdgIcon({
    Key? key,
    required this.name,
    required this.size,
    this.scale,
  }) : super(key: key);

  final String name;
  final int size;
  final int? scale;

  @override
  State<XdgIcon> createState() => _XdgIconState();
}

class _XdgIconState extends State<XdgIcon> {
  GtkIconInfo? _icon;
  GtkIconTheme? _theme;

  void _lookupIcon() {
    final XdgIconThemeData data = XdgIconTheme.of(context);

    _theme ??= data.theme?.isNotEmpty == true
        ? GtkIconTheme.custom(data.theme!)
        : GtkIconTheme();

    _icon = _theme!.lookupIcon(
      widget.name,
      size: widget.size,
      scale: widget.scale ?? data.scale,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lookupIcon();
  }

  @override
  void didUpdateWidget(covariant XdgIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.name != oldWidget.name ||
        widget.size != oldWidget.size ||
        widget.scale != oldWidget.scale) {
      _lookupIcon();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_icon == null) {
      return SizedBox.square(dimension: widget.size.toDouble());
    }
    final file = File(_icon!.fileName);
    if (file.existsSync()) {
      final builder = _icon!.isScalable ? SvgPicture.file : Image.file;
      return builder(
        file,
        height: widget.size.toDouble(),
        width: widget.size.toDouble(),
      );
    } else {
      final builder = _icon!.isScalable ? SvgPicture.memory : Image.memory;
      return builder(
        _icon!.load(),
        height: widget.size.toDouble(),
        width: widget.size.toDouble(),
      );
    }
  }
}
