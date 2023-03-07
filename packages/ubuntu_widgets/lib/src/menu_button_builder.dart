import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';

/// A builder widget that makes it straight-forward to build a menu button
/// for an arbitrary list of values.
///
/// The following example creates a menu button for choosing enum values:
/// ```dart
/// MenuButtonBuilder<MyEnum>(
///   values: MyEnum.values,
///   selected: model.enumValue,
///   onSelected: (value) => model.enumValue = value,
///   iconBuilder: (context, value, _) => _toIcon(value),
///   itemBuilder: (context, value, _) => Text(value.toString()),
/// )
/// ```
///
/// See also:
///  * [DropdownBuilder] - A similar builder widget but for dropdowns.
class MenuButtonBuilder<T> extends StatefulWidget {
  /// Creates a menu button with the given `values`.
  ///
  /// The `onSelected` callback is called when the user selects an item.
  ///
  /// The `itemBuilder` function is called for each item in the menu.
  /// The returned widgets are set as children of the menu items.
  ///
  /// The `iconBuilder` function is called for each item in the menu.
  /// The returned widgets are set as icons of the menu items.
  ///
  const MenuButtonBuilder({
    super.key,
    this.child,
    this.selected,
    required this.values,
    this.onSelected,
    this.iconBuilder,
    required this.itemBuilder,
  });

  /// An optional child widget placed as a label of the button.
  final Widget? child;

  /// The currently selected value.
  final T? selected;

  /// The list of values.
  ///
  /// For enums, use the enum's `values` constant.
  final List<T> values;

  /// Called when the user selects an item.
  final ValueChanged<T>? onSelected;

  /// Builds an icon for the given `value`.
  ///
  /// Note: The returned widget is set as an icon of [MenuItemButton].
  final ValueWidgetBuilder<T>? iconBuilder;

  /// Builds a menu item for the given `value`.
  ///
  /// Note: The returned widget is set as a child of [MenuItemButton].
  final ValueWidgetBuilder<T> itemBuilder;

  @override
  State<MenuButtonBuilder<T>> createState() => _MenuButtonBuilderState<T>();
}

class _MenuButtonBuilderState<T> extends State<MenuButtonBuilder<T>> {
  final _controller = MenuController();
  final _focusNode = FocusNode();
  double? _width;

  @override
  void initState() {
    super.initState();
    _updateWidth();
  }

  @override
  void didUpdateWidget(covariant MenuButtonBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != oldWidget.child ||
        widget.selected != oldWidget.selected) {
      _updateWidth();
    }
  }

  void _updateWidth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final width = (context.findRenderObject() as RenderBox?)?.size.width;
      if (_width != width) {
        setState(() => _width = width);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Null check operator used on a null value
    // _MenuDirectionalFocusAction.invoke:
    // orientation = anchor._parent!._orientation;
    return MenuAnchor(
      menuChildren: const [],
      child: MenuAnchor(
        controller: _controller,
        childFocusNode: _focusNode,
        crossAxisUnconstrained: false,
        style: MenuStyle(
          minimumSize: MaterialStatePropertyAll(Size(_width ?? 0, 0)),
        ),
        builder: (context, controller, child) {
          return child!;
        },
        menuChildren: widget.values.mapIndexed(_buildMenuItem).toList(),
        child: OutlinedButton(
          onPressed: () {
            _controller.open(position: _calculateOffset());
            _focusNode.requestFocus();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DefaultTextStyle(
                style: _labelStyle,
                child: Flexible(
                    child: widget.child != null
                        ? widget.child!
                        : widget.selected != null
                            ? widget.itemBuilder(
                                context, widget.selected as T, null)
                            : const SizedBox.shrink()),
              ),
              const SizedBox(width: 8),
              const Icon(YaruIcons.pan_down),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _labelStyle => Theme.of(context)
      .textTheme
      .labelLarge!
      .copyWith(overflow: TextOverflow.ellipsis);

  Offset _calculateOffset() {
    final padding = MenuTheme.of(context)
        .style
        ?.padding
        ?.resolve({})?.resolve(Directionality.of(context));
    return Offset(0, -(padding?.top ?? 8));
  }

  Widget _buildMenuItem(int index, T? value) {
    if (value == null) {
      return const Divider();
    }

    final button = OutlinedButtonTheme.of(context).style;
    final style = MenuItemButton.styleFrom(
      minimumSize: button?.minimumSize?.resolve({}) ?? const Size(0, 40),
      maximumSize:
          button?.maximumSize?.resolve({}) ?? const Size(double.infinity, 40),
      padding:
          button?.padding?.resolve({})?.resolve(Directionality.of(context)) ??
              const EdgeInsets.symmetric(horizontal: 16),
    );

    final isSelected = (widget.selected == null && index == 0) ||
        (widget.selected != null && widget.selected == value);

    return MenuItemButton(
      focusNode: isSelected ? _focusNode : null,
      leadingIcon: widget.iconBuilder?.call(context, value, null),
      onPressed: () {
        widget.onSelected?.call(value);
        _controller.close();
      },
      style: style,
      child: widget.itemBuilder(context, value, null),
    );
  }
}
