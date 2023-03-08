import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';

const _kItemHeight = 40.0;

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
    this.decoration = const InputDecoration(filled: false),
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

  /// An optional input decoration for the button.
  final InputDecoration decoration;

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
    return MenuAnchor(
      controller: _controller,
      crossAxisUnconstrained: false,
      style: MenuStyle(
        minimumSize: MaterialStatePropertyAll(Size(_width ?? 0, 0)),
      ),
      builder: (context, controller, child) {
        return child!;
      },
      menuChildren: widget.values.mapIndexed(_buildMenuItem).toList(),
      child: Stack(
        children: [
          Positioned.fill(
            child: InputDecorator(
              expands: true,
              decoration: widget.decoration,
              isEmpty: widget.selected == null && widget.child == null,
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(side: BorderSide.none),
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
                const Icon(YaruIcons.pan_down, size: 20),
              ],
            ),
          ),
        ],
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

  EdgeInsetsGeometry _scaledPadding(BuildContext context) {
    return ButtonStyleButton.scaledPadding(
      const EdgeInsets.symmetric(horizontal: 16),
      const EdgeInsets.symmetric(horizontal: 8),
      const EdgeInsets.symmetric(horizontal: 4),
      MediaQuery.maybeOf(context)?.textScaleFactor ?? 1,
    );
  }

  Widget _buildMenuItem(int index, T? value) {
    if (value == null) {
      return const Divider();
    }

    final states = {
      if (widget.selected == null && index == 0) MaterialState.selected,
      if (widget.selected != null && widget.selected == value)
        MaterialState.selected,
      if (widget.onSelected == null) MaterialState.disabled,
    };

    final direction = Directionality.of(context);

    final button = OutlinedButtonTheme.of(context).style;
    final minimumSize = button?.minimumSize?.resolve(states);
    final maximumSize = button?.maximumSize?.resolve(states);
    final padding = button?.padding?.resolve(states)?.resolve(direction);

    return MenuItemButton(
      focusNode: states.contains(MaterialState.selected) ? _focusNode : null,
      leadingIcon: widget.iconBuilder?.call(context, value, null),
      onPressed: () {
        widget.onSelected?.call(value);
        _controller.close();
      },
      style: MenuItemButton.styleFrom(
        minimumSize: minimumSize ?? const Size(0, _kItemHeight),
        maximumSize: maximumSize ?? const Size(double.infinity, _kItemHeight),
        padding: padding ?? _scaledPadding(context),
      ),
      child: widget.itemBuilder(context, value, null),
    );
  }
}
