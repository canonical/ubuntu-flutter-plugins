import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:path/path.dart' as path;

import 'package:xdg_icons/src/data.dart';
import 'package:xdg_icons/src/platform_interface.dart';
import 'package:xdg_icons/src/theme.dart';

typedef IconNotFoundBuilder = Widget Function();

class XdgIcon extends StatefulWidget {
  const XdgIcon({
    required this.name,
    this.size,
    this.scale,
    this.theme,
    this.iconNotFoundBuilder,
    super.key,
  });

  final String name;
  final int? size;
  final int? scale;
  final String? theme;
  final IconNotFoundBuilder? iconNotFoundBuilder;

  @override
  State<XdgIcon> createState() => XdgIconState();
}

class XdgIconState extends State<XdgIcon> {
  XdgIconData? _icon;
  StreamSubscription<dynamic>? _themeChange;
  bool _iconNotFound = false;

  XdgIconData? get icon => _icon;

  int _resolveSize() {
    final size = widget.size ?? XdgIconTheme.of(context).size;
    if (size == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Unable to resolve $widget size.'),
        ErrorDescription('Neither XdgIcon nor XdgIconTheme has size.'),
        ErrorHint(
          'Possible solutions:\n\n'
          '  XdgIcon(\n'
          '    name: \'${widget.name}\',\n'
          '    size: 48 // <==\n'
          '  )\n'
          '\n'
          '  XdgIconTheme(\n'
          '    data: XdgIconThemeData(size: 48), // <==\n'
          '    child: XdgIcon(\n'
          '      name: \'${widget.name}\'\n'
          '    )\n'
          '  )\n',
        ),
      ]);
    }
    return size;
  }

  Future<void> _lookupIcon() {
    final themeData = XdgIconTheme.of(context);
    return XdgIconsPlatform.instance
        .lookupIcon(
          name: widget.name,
          size: _resolveSize(),
          scale: widget.scale ?? themeData.scale,
          theme: widget.theme ?? themeData.theme,
        )
        .then(_updateIcon);
  }

  void _updateIcon(XdgIconData? icon) {
    if (_icon == icon || !mounted) {
      if (icon == null) {
        setState(() => _iconNotFound = true);
      }
      return;
    }
    setState(() {
      _icon = icon;
      _iconNotFound = icon == null;
    });
  }

  void _listenThemeChanges() {
    if (widget.theme == null && XdgIconTheme.of(context).theme == null) {
      _themeChange ??=
          XdgIconsPlatform.instance.onDefaultThemeChanged.listen((dynamic _) {
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
    final size = _resolveSize();
    if (file.existsSync()) {
      if (_icon!.isScalable) {
        return SizedBox(
          width: size.toDouble(),
          height: size.toDouble(),
          child: ScalableImageWidget.fromSISource(
            si: ScalableImageSource.fromSvgFile(
              file.path,
              file.readAsStringSync,
            ),
          ),
        );
      }

      return Image.file(
        file,
        width: size.toDouble(),
        height: size.toDouble(),
      );
    } else if (_icon?.data != null) {
      if (_icon!.isScalable) {
        return SizedBox(
          width: size.toDouble(),
          height: size.toDouble(),
          child: ScalableImageWidget.fromSISource(
            si: ScalableImageSource.fromSvgFile(
              file.path,
              () => utf8.decode(_icon!.data!),
            ),
          ),
        );
      }

      return Image.memory(
        Uint8List.fromList(_icon!.data!),
        width: size.toDouble(),
        height: size.toDouble(),
      );
    } else if (_iconNotFound && widget.iconNotFoundBuilder != null) {
      return widget.iconNotFoundBuilder!();
    }
    return SizedBox.square(dimension: size.toDouble());
  }
}

extension _XdgIconDataX on XdgIconData {
  bool get isScalable => path.extension(fileName).toLowerCase() == '.svg';
}
