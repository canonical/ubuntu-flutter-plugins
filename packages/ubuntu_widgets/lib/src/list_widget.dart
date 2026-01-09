import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru/widgets.dart';

// assumes dense list tiles
const _kTileHeight = kMinInteractiveDimension;

/// A list view that scrolls to the selected item and offers a callback for key
/// search.
class ListWidget extends StatefulWidget {
  /// Creates a new list widget with an item builder.
  const ListWidget.builder({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.selectedIndex = -1,
    this.onKeySearch,
    this.shrinkWrap = false,
  });

  /// The index of the selected item.
  final int selectedIndex;

  /// The number of items in the list.
  final int itemCount;

  /// The builder for the list items.
  final IndexedWidgetBuilder itemBuilder;

  /// Called when a key is pressed.
  final ValueChanged<String>? onKeySearch;

  /// Whether the list should shrink-wrap its contents or not.
  final bool shrinkWrap;

  @override
  State<ListWidget> createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  final _scrollableKey = GlobalKey();
  ScrollController? _scrollController;

  @override
  void didUpdateWidget(ListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scrollTo(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  void _scrollTo(int index) {
    if (index == -1 || _scrollController?.hasClients != true) return;

    final box = _scrollableKey.currentContext?.findRenderObject() as RenderBox?;
    if (box?.hasSize != true) return;

    final scrollOffset = _scrollController!.offset;
    final tileOffset = index * _kTileHeight;
    final viewHeight = box!.size.height;

    // jump and center align the selected item is fully outside the viewport
    if (tileOffset < scrollOffset - _kTileHeight ||
        tileOffset > scrollOffset + viewHeight) {
      final center = tileOffset - viewHeight / 2 + _kTileHeight / 2;
      _scrollController?.jumpTo(center);
    }
  }

  @override
  Widget build(BuildContext context) {
    return YaruBorderContainer(
      clipBehavior: Clip.antiAlias,
      // Wrap the list in a FocusScope to define it as a group in order to allow propper focus behaviour
      child: FocusScope(
        child: Builder(
          builder: (context) {
            return Focus(
              // Intercept Key Events to handle Tab to Exit
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.tab) {
                  // Get the current scope (the list)
                  final scope = FocusScope.of(context);

                  // Move focus in the PARENT scope (The Page).
                  // This jumps from the List to the Nex  or previous element
                  // completely skipping the internal list items.
                  if (HardwareKeyboard.instance.isShiftPressed) {
                    scope.enclosingScope?.previousFocus();
                  } else {
                    scope.enclosingScope?.nextFocus();
                  }

                  return KeyEventResult.handled;
                }

                // Let Arrow keys pass through to the ListView naturally
                return KeyEventResult.ignored;
              },
              child: KeySearch(
                onSearch: widget.onKeySearch ?? (_) => -1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (widget.itemCount <= 0 ||
                        constraints.maxWidth <= 0 ||
                        constraints.maxHeight <= 0) {
                      return const SizedBox.expand();
                    }
                    // calculate initial center-alignment
                    _scrollController ??= ScrollController(
                      initialScrollOffset: widget.selectedIndex * _kTileHeight -
                          constraints.maxHeight / 2 +
                          _kTileHeight / 2,
                    );
                    return FocusTraversalGroup(
                      policy: OrderedTraversalPolicy(),
                      child: ListView.builder(
                        key: _scrollableKey,
                        controller: _scrollController,
                        shrinkWrap: widget.shrinkWrap,
                        itemExtent: _kTileHeight,
                        itemCount: widget.itemCount,
                        itemBuilder: (context, index) => Builder(
                          builder: (context) {
                            if (index == widget.selectedIndex) {
                              // bring a half-visible selected item into the viewport
                              context.findRenderObject()?.showOnScreen();
                            }
                            return FocusTraversalOrder(
                              order: NumericFocusOrder(index.toDouble()),
                              child: widget.itemBuilder(context, index),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
