import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_localizations/ubuntu_localizations.dart';
import 'package:yaru_test/yaru_test.dart';

final _localizations = <Type, Object>{};

/// Widget test extensions.
extension UbuntuWidgetTester on WidgetTester {
  /// The [UbuntuLocalizations] instance.
  UbuntuLocalizations get ulang =>
      localizations<UbuntuLocalizations>(UbuntuLocalizations);

  /// Looks up a localizations instance.
  T localizations<T>(Type type) {
    if (_localizations.containsKey(T)) return _localizations[T] as T;

    final result = find.byWidgetPredicate((widget) {
      final context = element(find.byWidget(widget));
      return Localizations.of<T>(context, type) != null;
    });

    if (result.evaluate().isEmpty) {
      throw StateError('''
No $T found in the widget tree.

Pump a widget tree with `LocalizationsDelegate<$T>` before calling
`UbuntuWidgetTester.findLocalizations<$T>()`. For example:

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: $T.localizationsDelegates,
      home: ...
    ),
  );

  final l10n = tester.localizations<$T>();
  expect(find.text(l10n.fooLabel), findsOneWidget);
''');
    }

    final l10n = Localizations.of(element(result.first), T)!;
    _localizations[T] = l10n;
    if (_localizations.length == 1) addTearDown(_localizations.clear);
    return l10n;
  }

  /// Taps a _Back_ button.
  Future<void> tapBack() => tapButton(ulang.backLabel);

  /// Taps a _Cancel_ button.
  Future<void> tapCancel() => tapButton(ulang.cancelLabel);

  /// Taps a _Close_ button.
  Future<void> tapClose() => tapButton(ulang.closeLabel);

  /// Taps a _Continue_ button.
  Future<void> tapContinue() => tapButton(ulang.continueLabel);

  /// Taps a _Next_ button.
  Future<void> tapNext() => tapButton(ulang.nextLabel);

  /// Taps an _Ok_ button.
  Future<void> tapOk() => tapButton(ulang.okLabel);

  /// Taps a _Previous_ button.
  Future<void> tapPrevious() => tapButton(ulang.previousLabel);
}
