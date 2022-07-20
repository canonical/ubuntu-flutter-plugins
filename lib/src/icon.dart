import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as path;

import 'data.dart';
import 'platform_interface.dart';
import 'theme.dart';

class XdgIcon extends StatefulWidget {
  const XdgIcon({
    super.key,
    required this.name,
    this.size,
    this.scale,
    this.theme,
  });

  final String name;
  final int? size;
  final int? scale;
  final String? theme;

  @override
  State<XdgIcon> createState() => XdgIconState();
}

class XdgIconState extends State<XdgIcon> {
  XdgIconData? _icon;
  StreamSubscription? _themeChange;

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
    if (_icon == icon || !mounted) return;
    setState(() => _icon = icon);
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
      final builder = _icon!.isScalable ? SvgPicture.file : Image.file;
      return builder(
        file,
        width: size.toDouble(),
        height: size.toDouble(),
      );
    } else if (_icon?.data != null) {
      final builder = _icon!.isScalable ? SvgPicture.memory : Image.memory;
      return builder(
        Uint8List.fromList(_icon!.data!),
        width: size.toDouble(),
        height: size.toDouble(),
      );
    }
    return SizedBox.square(dimension: size.toDouble());
  }
}

extension XdgIconDataX on XdgIconData {
  bool get isScalable => path.extension(fileName).toLowerCase() == '.svg';
}
