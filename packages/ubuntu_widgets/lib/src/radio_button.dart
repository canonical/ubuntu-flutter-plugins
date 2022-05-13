import 'package:flutter/material.dart';

import 'toggle_button.dart';

/// A desktop style radio button with an interactive label.
class RadioButton<T> extends StatelessWidget {
  /// Creates a new radio button.
  const RadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.contentPadding,
  });

  /// See [Radio.value]
  final T value;

  /// See [Radio.groupValue]
  final T? groupValue;

  /// See [Radio.onChanged]
  final ValueChanged<T?>? onChanged;

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
          child: Radio<T>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
          ),
        ),
      ),
      onToggled: onChanged != null ? () => onChanged!(value) : null,
    );
  }
}
