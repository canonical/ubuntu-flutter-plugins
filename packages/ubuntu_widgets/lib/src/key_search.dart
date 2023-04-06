import 'dart:async';

import 'package:diacritic/diacritic.dart';
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
    if (event is KeyDownEvent &&
        event.character?.isNotEmpty == true &&
        !LogicalKeyboardKey.isControlCharacter(event.character!)) {
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

/// Searches a list in a way that is most appropriate for keyboard searching.
extension KeySearchX on List<String> {
  /// Searches for an element matching the given [query].
  ///
  /// The search is case-insensitive, ignores diacritics, starts from the given
  /// index, and wraps around if not found.
  int keySearch(String query, [int start = 0]) {
    String cleanup(String s) => removeDiacritics(s).trim().toLowerCase();

    final q = cleanup(query);
    if (q.isEmpty) return -1;

    bool startsWith(String s) => cleanup(s).startsWith(q);

    final index = indexWhere(startsWith, start);
    return index != -1 || start == 0
        ? index
        : take(start).toList().indexWhere(startsWith);
  }
}
