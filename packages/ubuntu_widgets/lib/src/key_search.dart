library key_search;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The default key search interval.
const kKeySearchInterval = Duration(milliseconds: 500);

/// Listens to key events and calls [onSearch] when a key sequence is typed.
class KeySearch extends StatefulWidget {
  /// Creates a key search widget.
  const KeySearch({
    super.key,
    this.autofocus = false,
    this.focusNode,
    this.interval = kKeySearchInterval,
    required this.onSearch,
    required this.child,
  });

  /// Whether to autofocus the key search.
  final bool autofocus;

  /// The focus node for the key search.
  final FocusNode? focusNode;

  /// The duration to wait since the last key event before calling [onSearch].
  final Duration interval;

  /// Called when a key sequence is typed.
  final ValueChanged<String> onSearch;

  /// The child widget.
  final Widget child;

  @override
  State<KeySearch> createState() => _KeySearchState();
}

class _KeySearchState extends State<KeySearch> {
  var _searchQuery = '';
  Timer? _searchTimer;

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  KeyEventResult search(KeyEvent event) {
    if (event is KeyDownEvent && event.character != null) {
      _searchQuery += event.character!;
      _searchTimer?.cancel();
      _searchTimer = Timer(widget.interval, () {
        widget.onSearch(_searchQuery);
        _searchQuery = '';
      });
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      onKeyEvent: (node, event) => search(event),
      child: widget.child,
    );
  }
}
