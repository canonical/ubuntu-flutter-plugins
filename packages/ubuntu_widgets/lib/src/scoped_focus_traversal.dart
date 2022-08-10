import 'package:flutter/widgets.dart';

/// A scoped focus traversal group.
///
/// Commonly used to build desktop-style focus traversal scopes so that Tab
/// focus traverses first the "selected" list item, and vertical key navigation
/// is contained within the list view.
///
/// ```dart
/// ScopedFocusTraversalGroup(
///   child: ListView.builder(
///     itemCount: 10,
///     itemBuilder: (context, index) {
///       return ScopedFocusTraversalOrder(
///         focus: index == _selectedIndex,
///         child: ListTile(
///           selected: index == _selectedIndex,
///           // ...
///         ),
///       );
///     },
///   ),
/// )
/// ```
///
/// See also:
///
///  * [ScopedFocusTraversalOrder]
///  * [ScopedFocusTraversalPolicy]
class ScopedFocusTraversalGroup extends FocusTraversalGroup {
  /// Constructs a scoped focus traversal group.
  ScopedFocusTraversalGroup({
    super.key,
    required super.child,
    FocusTraversalPolicy? secondary,
  }) : super(policy: ScopedFocusTraversalPolicy(secondary: secondary));
}

/// A scoped focus traversal order.
///
/// See also:
///
///  * [ScopedFocusTraversalGroup]
///  * [ScopedFocusTraversalPolicy]
class ScopedFocusTraversalOrder extends StatelessWidget {
  /// Constructs a scoped focus traversal order.
  const ScopedFocusTraversalOrder({
    super.key,
    required this.child,
    this.focus = false,
  });

  /// Whether the child requests focus.
  final bool focus;

  /// The child of this widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!focus) return child;
    return FocusTraversalOrder(
      order: const NumericFocusOrder(0),
      child: child,
    );
  }
}

/// A scoped focus traversal policy.
///
/// See also:
///
///  * [ScopedFocusTraversalGroup]
///  * [ScopedFocusTraversalOrder]
class ScopedFocusTraversalPolicy extends FocusTraversalPolicy {
  /// Constructs a scoped focus traversal policy.
  ScopedFocusTraversalPolicy({FocusTraversalPolicy? secondary})
      : secondary = secondary ?? OrderedTraversalPolicy(secondary: secondary);

  /// The policy to use as a secondary focus traversal order.
  final FocusTraversalPolicy secondary;

  @override
  Iterable<FocusNode> sortDescendants(
    Iterable<FocusNode> descendants,
    FocusNode currentNode,
  ) {
    if (descendants.contains(primaryFocus)) {
      return [primaryFocus!];
    }
    final sorted = secondary.sortDescendants(descendants, currentNode);
    return sorted.isNotEmpty ? [sorted.first] : [];
  }

  @override
  FocusNode? findFirstFocusInDirection(
      FocusNode currentNode, TraversalDirection direction) {
    return findFirstFocus(currentNode);
  }

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    final focusedChild = currentNode.nearestScope?.focusedChild;
    final children = currentNode.parent?.traversalChildren ?? [];
    // assumes that the scope is a vertical list. expose an axes property if
    // more control is needed.
    if ((direction == TraversalDirection.up &&
            focusedChild == children.first) ||
        (direction == TraversalDirection.down &&
            focusedChild == children.last)) {
      return false;
    }
    return secondary.inDirection(currentNode, direction);
  }
}
