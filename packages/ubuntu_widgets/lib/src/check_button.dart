import 'package:flutter/material.dart';

import 'toggle_button.dart';

/// A desktop style check button with an interactive label.
class CheckButton extends StatelessWidget {
  /// Creates a new check button.
  const CheckButton({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.contentPadding,
  }) : super(key: key);

  /// See [Checkbox.value]
  final bool value;

  /// See [Checkbox.onChanged]
  final ValueChanged<bool?>? onChanged;

  /// See [ToggleButton.title]
  final Widget title;

  /// See [ToggleButton.subtitle]
  final Widget? subtitle;

  /// See [ToggleButton.contentPadding]
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return ToggleButton(
      title: title,
      subtitle: subtitle,
      contentPadding: contentPadding,
      leading: SizedBox.square(
        dimension: kMinInteractiveDimension - 8,
        child: Center(
          child: Checkbox(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ),
      onToggled: onChanged != null ? () => onChanged!(!value) : null,
    );
  }
}
