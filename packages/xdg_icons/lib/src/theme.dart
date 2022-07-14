import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class XdgIconThemeData with Diagnosticable {
  const XdgIconThemeData({this.theme, this.size, this.scale});

  final String? theme;
  final int? size;
  final int? scale;

  XdgIconThemeData copyWith({String? theme, int? size, int? scale}) {
    return XdgIconThemeData(
      theme: theme ?? this.theme,
      size: size ?? size,
      scale: scale ?? this.scale,
    );
  }

  XdgIconThemeData merge(XdgIconThemeData? other) {
    if (other == null) return this;
    return copyWith(theme: other.theme, size: other.size, scale: other.scale);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is XdgIconThemeData &&
        theme == other.theme &&
        size == other.size &&
        scale == other.scale;
  }

  @override
  int get hashCode => Object.hash(theme, size, scale);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('theme', theme, defaultValue: null));
    properties.add(IntProperty('size', size, defaultValue: null));
    properties.add(IntProperty('scale', scale, defaultValue: null));
  }
}

class XdgIconTheme extends InheritedTheme {
  const XdgIconTheme({super.key, required this.data, required super.child});

  final XdgIconThemeData data;

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

  static XdgIconThemeData of(BuildContext context) {
    return _getInheritedTheme(context);
  }

  static XdgIconThemeData _getInheritedTheme(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<XdgIconTheme>();
    return theme?.data ?? const XdgIconThemeData();
  }

  @override
  bool updateShouldNotify(XdgIconTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return XdgIconTheme(data: data, child: child);
  }
}
