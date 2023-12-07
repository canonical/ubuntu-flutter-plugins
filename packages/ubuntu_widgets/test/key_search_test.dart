import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_widgets/src/key_search.dart';

void main() {
  testWidgets('key events', (tester) async {
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
    await tester.pumpAndSettle();
    expect(searchQuery, 'a');
    searchQuery = null;

    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(searchQuery, isNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyO);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(searchQuery, isNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyO);
    await tester.pumpAndSettle();
    expect(searchQuery, 'foo');
  });

  test('key search', () async {
    final languages = [
      'Dansk',
      'Deutsch',
      'English',
      'Español',
      'Français',
      'Íslenska',
      'Norsk',
    ];

    final english = languages.keySearch('eng');
    expect(languages[english], equals('English'));
    expect(languages.keySearch('eng', english), english);

    // next language with the same prefix
    final spanish = languages.keySearch('e', english + 1);
    expect(languages[spanish], equals('Español'));

    // case-insensitive
    final french = languages.keySearch('FRA');
    expect(languages[french], equals('Français'));

    // wrap around
    final danish = languages.keySearch('d', french);
    expect(languages[danish], equals('Dansk'));

    // ignores diacritics
    final icelandic = languages.keySearch('is');
    expect(languages[icelandic], equals('Íslenska'));

    // no match
    expect(languages.keySearch(''), isNegative);
    expect(languages.keySearch(' '), isNegative);
    expect(languages.keySearch('foo'), isNegative);
    expect(languages.keySearch('none'), isNegative);
  });
}
