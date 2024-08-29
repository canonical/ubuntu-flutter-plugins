import 'package:flutter/material.dart';

/// This widget is a text that can be clicked and when it is hovered it changes
/// its style, by default to underline + primary color, but that can be
/// customized with [textHoverStyle].
class ClickableText extends StatefulWidget {
  const ClickableText(
    this.text, {
    this.onTap,
    this.textStyle,
    this.textHoverStyle,
    super.key,
  });

  final String text;
  final VoidCallback? onTap;
  final TextStyle? textStyle;
  final TextStyle? textHoverStyle;

  @override
  ClickableTextState createState() => ClickableTextState();
}

class ClickableTextState extends State<ClickableText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          widget.text,
          style: _isHovered
              ? (widget.textHoverStyle ??
                  TextStyle(
                    color: colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ))
              : widget.textStyle,
        ),
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
      ),
    );
  }
}
