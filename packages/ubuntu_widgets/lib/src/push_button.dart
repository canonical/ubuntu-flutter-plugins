import 'package:flutter/material.dart';

/// The minimum size of a push button.
const kPushButtonSize = Size(136, 40);

/// A classic push button for desktop.
abstract class PushButton extends ButtonStyleButton {
  /// An elevated push button.
  ///
  /// See also:
  ///  * [ElevatedButton]
  const factory PushButton.elevated({
    required Widget child,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool autofocus,
    Clip clipBehavior,
    MaterialStatesController? statesController,
    Key? key,
  }) = _ElevatedPushButton;

  /// A filled push button.
  ///
  /// See also:
  ///  * [FilledButton]
  const factory PushButton.filled({
    required Widget child,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool autofocus,
    Clip clipBehavior,
    MaterialStatesController? statesController,
    Key? key,
  }) = _FilledPushButton;

  /// An outlined push button.
  ///
  /// See also:
  ///  * [OutlinedButton]
  const factory PushButton.outlined({
    required Widget child,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool autofocus,
    Clip clipBehavior,
    MaterialStatesController? statesController,
    Key? key,
  }) = _OutlinedPushButton;
}

class _ElevatedPushButton extends ElevatedButton implements PushButton {
  const _ElevatedPushButton({
    required super.child,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior = Clip.none,
    super.statesController,
    super.key,
  });

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    return super.defaultStyleOf(context).applyMinimumSize(kPushButtonSize);
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    return ElevatedButtonTheme.of(context)
        .style
        ?.applyMinimumSize(kPushButtonSize);
  }
}

class _FilledPushButton extends FilledButton implements PushButton {
  const _FilledPushButton({
    required super.child,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior = Clip.none,
    super.statesController,
    super.key,
  });

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    return super.defaultStyleOf(context).applyMinimumSize(kPushButtonSize);
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    return FilledButtonTheme.of(context)
        .style
        ?.applyMinimumSize(kPushButtonSize);
  }
}

class _OutlinedPushButton extends OutlinedButton implements PushButton {
  const _OutlinedPushButton({
    required super.child,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior = Clip.none,
    super.statesController,
    super.key,
  });

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    return super.defaultStyleOf(context).applyMinimumSize(kPushButtonSize);
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    return OutlinedButtonTheme.of(context)
        .style
        ?.applyMinimumSize(kPushButtonSize);
  }
}

extension on ButtonStyle {
  ButtonStyle applyMinimumSize(Size size) {
    return copyWith(minimumSize: MaterialStateProperty.all(size));
  }
}
