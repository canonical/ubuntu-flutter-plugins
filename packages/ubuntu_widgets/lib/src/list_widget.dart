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
  final FocusNode _wrapperNode = FocusNode(debugLabel: 'ListWrapper');
  final FocusNode _anchorNode = FocusNode(debugLabel: 'ListAnchor');

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
    _wrapperNode.dispose();
    _anchorNode.dispose();
    super.dispose();
  }

  void _scrollTo(int index) {
    if (index == -1 || _scrollController?.hasClients != true) return;

    final box = _scrollableKey.currentContext?.findRenderObject() as RenderBox?;
    if (box?.hasSize != true) return;

    final viewHeight = box!.size.height;
    final scrollOffset = _scrollController!.offset;
    final tileTop = index * _kTileHeight;
    final tileBottom = tileTop + _kTileHeight;

  // Check if the tile is off-screen (even partially)
    if (tileTop < scrollOffset || tileBottom > scrollOffset + viewHeight) {
      final distance = (tileTop - scrollOffset).abs();

      if (distance > viewHeight) {
        final center = tileTop - viewHeight / 2 + _kTileHeight / 2;
        _scrollController?.jumpTo(center);
      }
      // If it's just above the viewport, align it to the top.
      else if (tileTop < scrollOffset) {
        _scrollController?.jumpTo(tileTop);
      }
      // If it's just below the viewport, align it to the bottom.
      else {
        _scrollController?.jumpTo(tileBottom - viewHeight);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedIndex = widget.selectedIndex < 0
        ? 0
        : widget.selectedIndex;
    return YaruBorderContainer(
      clipBehavior: Clip.antiAlias,
      // Wrap the list in a FocusScope to define it as a group in order to allow propper focus behaviour
      child: FocusScope(
        child: Builder(
          builder: (context) {
            return Focus(
              focusNode: _wrapperNode,
              canRequestFocus: true,
              onFocusChange: (hasFocus) {
                if (hasFocus && _wrapperNode.hasPrimaryFocus) {
                  if (_anchorNode.canRequestFocus) {
                    _anchorNode.requestFocus();
                  }
                }
              },
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
                    final double rawOffset =
                        effectiveSelectedIndex * _kTileHeight -
                        constraints.maxHeight / 2 +
                        _kTileHeight / 2;

                    _scrollController ??= ScrollController(
                      initialScrollOffset: rawOffset < 0 ? 0.0 : rawOffset,
                    );

                    return FocusTraversalGroup(
                      policy: OrderedTraversalPolicy(),
                      child: ListView.builder(
                        key: _scrollableKey,
                        controller: _scrollController,
                        shrinkWrap: widget.shrinkWrap,
                        itemExtent: _kTileHeight,
                        itemCount: widget.itemCount,
                        itemBuilder: (context, index) {
                          Widget item = widget.itemBuilder(context, index);

                          if (index == widget.selectedIndex) {
                            item = Builder(
                              builder: (ctx) {
                                ctx.findRenderObject()?.showOnScreen();
                                return widget.itemBuilder(context, index);
                              },
                            );
                          }

                          final isEffectiveAnchor =
                              index == effectiveSelectedIndex;

                          item = Focus(
                            focusNode: isEffectiveAnchor ? _anchorNode : null,
                            canRequestFocus: isEffectiveAnchor,
                            skipTraversal: true,
                            onFocusChange: isEffectiveAnchor
                                ? (hasFocus) {
                                    if (hasFocus &&
                                        _anchorNode.hasPrimaryFocus) {
                                      _anchorNode.nextFocus();
                                    }
                                  }
                                : null,
                            onKeyEvent: (node, event) {
                              if (event is KeyDownEvent) {
                                if (index == widget.itemCount - 1 &&
                                    event.logicalKey ==
                                        LogicalKeyboardKey.arrowDown) {
                                  return KeyEventResult.handled;
                                }
                                if (index == 0 &&
                                    event.logicalKey ==
                                        LogicalKeyboardKey.arrowUp) {
                                  return KeyEventResult.handled;
                                }
                              }
                              return KeyEventResult.ignored;
                            },
                            child: item,
                          );

                          return FocusTraversalOrder(
                            order: NumericFocusOrder(index.toDouble()),
                            child: item,
                          );
                        },
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
