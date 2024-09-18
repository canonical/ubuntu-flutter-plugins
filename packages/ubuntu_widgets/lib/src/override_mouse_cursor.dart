import 'package:flutter/widgets.dart';

/// Overrides the mouse cursor for a subtree of widgets by stacking a mouse
/// region on top of the child.
///
/// NOTE: This is intended as a workaround for widgets that do not support
/// themeable mouse cursors. Prefer using FooThemeData.mouseCursor instead
/// whenever possible.
class OverrideMouseCursor extends StatelessWidget {
  /// Creates an instance.
  const OverrideMouseCursor({
    required this.child,
    required this.cursor,
    super.key,
  });

  /// The child widget.
  final Widget child;

  /// The overridden mouse cursor.
  final MouseCursor cursor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: MouseRegion(cursor: cursor, opaque: false),
        ),
      ],
    );
  }
}
