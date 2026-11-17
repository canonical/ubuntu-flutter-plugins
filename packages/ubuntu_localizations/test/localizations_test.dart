import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_localizations/src/flutter/flutter_localizations.dart';
import 'package:ubuntu_localizations/ubuntu_localizations.dart';

void main() {
  testWidgets('material supports all ubuntu localizations', (tester) async {
    final delegates = [
      GlobalMaterialLocalizations.delegate,
      ...FlutterMaterialLocalizations.delegates,
    ];

    for (final locale in UbuntuLocalizations.supportedLocales) {
      expect(
        delegates.any((delegate) => delegate.isSupported(locale)),
        isTrue,
        reason:
            'MaterialLocalizations for "$locale" not found. Is the delegate is missing?',
      );

      final delegate =
          delegates.firstWhere((delegate) => delegate.isSupported(locale));
      await expectLater(
        () async => delegate.load(locale),
        returnsNormally,
        reason:
            'MaterialLocalizations failed to load "$locale". Missing date time patters/symbols?',
      );
    }
  });

  testWidgets('cupertino supports all ubuntu localizations', (tester) async {
    final delegates = [
      GlobalCupertinoLocalizations.delegate,
      ...FlutterCupertinoLocalizations.delegates,
    ];

    for (final locale in UbuntuLocalizations.supportedLocales) {
      expect(
        delegates.any((delegate) => delegate.isSupported(locale)),
        isTrue,
        reason:
            'CupertinoLocalizations for "$locale" not found. Is the delegate is missing?',
      );

      final delegate =
          delegates.firstWhere((delegate) => delegate.isSupported(locale));
      await expectLater(
        () async => delegate.load(locale),
        returnsNormally,
        reason:
            'CupertinoLocalizations failed to load "$locale". Missing date time patters/symbols?',
      );
    }
  });

  testWidgets('Ubuntu-first delegates preserve native translations',
      (tester) async {
    final labelsByLanguage = <String, List<String>>{};
    for (final locale in UbuntuLocalizations.supportedLocales) {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: UbuntuLocalizations.supportedLocales,
          localizationsDelegates: const [
            ...GlobalUbuntuLocalizations.delegates,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: Builder(
            builder: (context) => Text(
              '${MaterialLocalizations.of(context).cancelButtonLabel}|'
              '${CupertinoLocalizations.of(context).cancelButtonLabel}|'
              '${UbuntuLocalizations.of(context).backAction}',
              key: const Key('labels'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'locale: $locale');
      final labels = tester.widget<Text>(find.byKey(const Key('labels'))).data!;
      labelsByLanguage[locale.languageCode] =
          labels.split('|').take(2).toList();
    }
    expect(labelsByLanguage['cy'], ['Canslo', 'Canslo']);
    expect(labelsByLanguage['bo'], ['ཕྱིར་འཐེན།', 'ཕྱིར་འཐེན།']);
    // Keep the existing missing-locale fallback policy unchanged.
    expect(labelsByLanguage['eo'], ['Avbryt', 'Avbryt']);
  });
}
