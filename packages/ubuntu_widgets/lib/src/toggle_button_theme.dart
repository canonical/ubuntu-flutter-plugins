import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Defines default property values for descendant [ToggleButton] widgets.
///
/// Descendant widgets obtain the current [ToggleButtonThemeData] object using
/// `ToggleButtonTheme.of(context)`. Instances of [ToggleButtonThemeData] can be
/// customized with [ToggleButtonThemeData.copyWith].
@immutable
class ToggleButtonThemeData with Diagnosticable {
  /// Creates a theme that can be used for [ToggleButtonTheme.data].
  const ToggleButtonThemeData({
    this.horizontalSpacing,
    this.verticalSpacing,
  });

  /// The spacing between the indicator and the title.
  final double? horizontalSpacing;

  /// The spacing between the title and the subtitle.
  final double? verticalSpacing;

  /// Creates a copy with the given fields replaced with new values.
  ToggleButtonThemeData copyWith({
    double? horizontalSpacing,
    double? verticalSpacing,
  }) {
    return ToggleButtonThemeData(
      horizontalSpacing: horizontalSpacing ?? this.horizontalSpacing,
      verticalSpacing: verticalSpacing ?? this.verticalSpacing,
    );
  }

  @override
  int get hashCode => Object.hash(horizontalSpacing, verticalSpacing);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ToggleButtonThemeData &&
        other.horizontalSpacing == horizontalSpacing &&
        other.verticalSpacing == verticalSpacing;
  }
}

/// Applies a theme to descendant [ToggleButton] widgets.
///
/// Descendant widgets obtain the current [ToggleButtonTheme] object using
/// [ToggleButtonTheme.of]. When a widget uses [ToggleButtonTheme.of], it is
/// automatically rebuilt if the theme later changes.
///
/// See also:
///
///  * [ToggleButtonThemeData], which describes the actual configuration of a
///  toggle button theme.
class ToggleButtonTheme extends InheritedWidget {
  /// Constructs a checkbox theme that configures all descendant [ToggleButton]
  /// widgets.
  const ToggleButtonTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The properties used for all descendant [ToggleButton] widgets.
  final ToggleButtonThemeData data;

  /// Returns the configuration [data] from the closest [ToggleButtonTheme]
  /// ancestor. If there is no ancestor, it returns `null`.
  static ToggleButtonThemeData? of(BuildContext context) {
    final t = context.dependOnInheritedWidgetOfExactType<ToggleButtonTheme>();
    return t?.data;
  }

  @override
  bool updateShouldNotify(ToggleButtonTheme oldWidget) {
    return data != oldWidget.data;
  }
}
