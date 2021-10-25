import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'icon.dart';
import 'icons.dart';
import 'theme.dart';

class XdgIcon extends StatefulWidget {
  const XdgIcon({
    Key? key,
    required this.name,
    this.size,
    this.scale,
  }) : super(key: key);

  final String name;
  final int? size;
  final int? scale;

  @override
  State<XdgIcon> createState() => _XdgIconState();
}

class _XdgIconState extends State<XdgIcon> {
  XdgIconData? _icon;

  void _lookupIcon() {
    final XdgIconThemeData theme = XdgIconTheme.of(context);
    final size = widget.size ?? theme.size ?? XdgIcons.defaultSize;
    final scale = widget.scale ?? theme.scale ?? XdgIcons.defaultScale;

    assert(theme.name != null || theme.path != null);
    final info = theme.name != null
        ? XdgIconThemeInfo.fromName(theme.name!)
        : XdgIconThemeInfo.fromPath(theme.path!);

    info.then((info) {
      print('${widget.name}, theme: ${theme.name}, size: $size, scale: $scale');

      info?.findIcon(widget.name, size, scale).then((icon) {
        print('found: $icon');
        setState(() => _icon = icon);
      });
    });
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
    final XdgIconThemeData theme = XdgIconTheme.of(context);
    final size = widget.size ?? theme.size ?? XdgIcons.defaultSize;
    if (_icon == null) {
      return SizedBox(width: size.toDouble(), height: size.toDouble());
    }
    return Image.file(
      File(_icon!.path),
      height: size.toDouble(),
      width: size.toDouble(),
    );
  }
}

@immutable
class XdgIconThemeData with Diagnosticable {
  const XdgIconThemeData({
    this.name,
    this.path,
    this.size,
    this.scale,
  }) : assert(name != null || path != null);

  factory XdgIconThemeData.system() {
    return XdgIconThemeData(
      name: XdgIcons.systemTheme,
      size: XdgIcons.defaultSize,
      scale: XdgIcons.defaultScale,
    );
  }

  XdgIconThemeData copyWith({
    String? name,
    String? path,
    int? size,
    int? scale,
  }) {
    return XdgIconThemeData(
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      scale: scale ?? this.scale,
    );
  }

  XdgIconThemeData merge(XdgIconThemeData? other) {
    if (other == null) return this;
    return copyWith(
      name: other.name,
      path: other.path,
      size: other.size,
      scale: other.scale,
    );
  }

  XdgIconThemeData resolve(BuildContext context) => this;

  bool get isConcrete =>
      (name != null || path != null) && size != null && scale != null;

  final String? name;
  final String? path;
  final int? size;
  final int? scale;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is XdgIconThemeData &&
        other.name == name &&
        other.path == path &&
        other.size == size &&
        other.scale == scale;
  }

  @override
  int get hashCode => hashValues(name, path, size, scale);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('name', name, defaultValue: null));
    properties.add(StringProperty('path', path, defaultValue: null));
    properties.add(IntProperty('size', size, defaultValue: null));
    properties.add(IntProperty('scale', scale, defaultValue: null));
  }
}

class XdgIconTheme extends InheritedTheme {
  const XdgIconTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  static Widget merge({
    Key? key,
    required XdgIconThemeData data,
    required Widget child,
  }) {
    return Builder(
      builder: (BuildContext context) {
        return XdgIconTheme(
          key: key,
          data: _getInheritedTheme(context).merge(data),
          child: child,
        );
      },
    );
  }

  final XdgIconThemeData data;

  static XdgIconThemeData of(BuildContext context) {
    final XdgIconThemeData theme = _getInheritedTheme(context).resolve(context);
    return theme.isConcrete
        ? theme
        : theme.copyWith(
            name: theme.name ?? XdgIconThemeData.system().name,
            size: theme.size ?? XdgIconThemeData.system().size,
            scale: theme.size ?? XdgIconThemeData.system().scale,
          );
  }

  static XdgIconThemeData _getInheritedTheme(BuildContext context) {
    final XdgIconTheme? theme =
        context.dependOnInheritedWidgetOfExactType<XdgIconTheme>();
    return theme?.data ?? XdgIconThemeData.system();
  }

  @override
  bool updateShouldNotify(XdgIconTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return XdgIconTheme(data: data, child: child);
  }
}
