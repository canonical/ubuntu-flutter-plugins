import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'toggle_button_theme.dart';

part 'toggle_button_layout.dart';

/// A desktop style toggle button with an indicator and an interactive label.
///
/// See [CheckButton] and [RadioButton] for concrete implementations.
class ToggleButton extends StatelessWidget {
  /// Creates a toggle button.
  const ToggleButton({
    Key? key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.contentPadding,
    this.onToggled,
  }) : super(key: key);

  /// The toggle indicator.
  final Widget leading;

  /// The button label.
  final Widget title;

  /// An optional secondary label.
  final Widget? subtitle;

  /// Padding around the content.
  final EdgeInsetsGeometry? contentPadding;

  /// Called when the button is toggled.
  final VoidCallback? onToggled;

  @override
  Widget build(BuildContext context) {
    final theme = ToggleButtonTheme.of(context);
    return MergeSemantics(
      child: Semantics(
        child: GestureDetector(
          onTap: onToggled,
          child: MouseRegion(
            cursor: onToggled != null
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: Padding(
              padding: contentPadding ?? EdgeInsets.zero,
              child: _ToggleButtonLayout(
                horizontalSpacing: theme?.horizontalSpacing ?? 8,
                verticalSpacing: theme?.verticalSpacing ?? 4,
                textDirection: Directionality.of(context),
                leading: leading,
                title: _wrapTextStyle(
                  context,
                  style: Theme.of(context).textTheme.subtitle1!,
                  child: title,
                ),
                subtitle: subtitle != null
                    ? _wrapTextStyle(
                        context,
                        style: Theme.of(context).textTheme.caption!,
                        child: subtitle!,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrapTextStyle(
    BuildContext context, {
    required Widget child,
    required TextStyle style,
  }) {
    final color = onToggled == null ? Theme.of(context).disabledColor : null;
    return DefaultTextStyle(
      style: style.copyWith(color: color),
      overflow: TextOverflow.ellipsis,
      child: child,
    );
  }
}
