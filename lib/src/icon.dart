import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as path;
import 'package:xdg_icons/src/platform_interface.dart';

import 'data.dart';
import 'theme.dart';

class XdgIcon extends StatefulWidget {
  const XdgIcon({
    super.key,
    required this.name,
    required this.size,
    this.scale,
    this.theme,
  });

  final String name;
  final int size;
  final int? scale;
  final String? theme;

  @override
  State<XdgIcon> createState() => _XdgIconState();
}

class _XdgIconState extends State<XdgIcon> {
  XdgIconData? _icon;
  StreamSubscription? _themeChange;

  Future<void> _lookupIcon() {
    final themeData = XdgIconTheme.of(context);
    return XdgPlatform.instance
        .lookupIcon(
          name: widget.name,
          size: widget.size,
          scale: widget.scale ?? themeData.scale,
          theme: widget.theme ?? themeData.theme,
        )
        .then(_updateIcon);
  }

  void _updateIcon(XdgIconData? icon) {
    if (_icon == icon) return;
    setState(() => _icon = icon);
  }

  void _listenThemeChanges() {
    if (widget.theme == null && XdgIconTheme.of(context).theme == null) {
      _themeChange ??= XdgPlatform.instance.onDefaultThemeChanged.listen((_) {
        if (mounted) _lookupIcon();
      });
    } else {
      _themeChange?.cancel();
      _themeChange = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lookupIcon();
    _listenThemeChanges();
  }

  @override
  void didUpdateWidget(covariant XdgIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.name != oldWidget.name ||
        widget.size != oldWidget.size ||
        widget.scale != oldWidget.scale ||
        widget.theme != oldWidget.theme) {
      _lookupIcon();
      _listenThemeChanges();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _themeChange?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final file = File(_icon?.fileName ?? '');
    if (file.existsSync()) {
      final builder = _icon!.isScalable ? SvgPicture.file : Image.file;
      return builder(
        file,
        height: widget.size.toDouble(),
        width: widget.size.toDouble(),
      );
    } else if (_icon?.data != null) {
      final builder = _icon!.isScalable ? SvgPicture.memory : Image.memory;
      return builder(
        Uint8List.fromList(_icon!.data!),
        height: widget.size.toDouble(),
        width: widget.size.toDouble(),
      );
    }
    return SizedBox.square(dimension: widget.size.toDouble());
  }
}

extension XdgIconDataX on XdgIconData {
  bool get isScalable => path.extension(fileName).toLowerCase() == '.svg';
}
