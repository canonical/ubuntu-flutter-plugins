import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_widgets/src/key_search.dart';

void main() {
  testWidgets('TODO', (tester) async {
    String? searchQuery;

    await tester.pumpWidget(
      KeySearch(
        autofocus: true,
        interval: const Duration(milliseconds: 100),
        onSearch: (value) => searchQuery = value,
        child: const SizedBox.shrink(),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    expect(searchQuery, isNull);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(searchQuery, 'a');
    searchQuery = null;

    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(searchQuery, isNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyO);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(searchQuery, isNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyO);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(searchQuery, 'foo');
  });
}
