import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:ubuntu_localizations/ubuntu_localizations.dart';

void main() {
  // Keep this in its own file: global delegates cache date formatters, so loading
  // other locales first can hide missing date data on application startup.
  testWidgets('Tibetan startup loads translated strings and dates',
      (tester) async {
    final previousLocale = Intl.defaultLocale;
    addTearDown(() => Intl.defaultLocale = previousLocale);
    Intl.defaultLocale = 'bo';

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('bo'),
        supportedLocales: const [Locale('bo')],
        localizationsDelegates: const [
          ...GlobalUbuntuLocalizations.delegates,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: Builder(
          builder: (context) {
            final material = MaterialLocalizations.of(context);
            final apple = CupertinoLocalizations.of(context);
            final date = DateTime(2026, 1, 15);
            return Column(
              children: [
                Text(material.cancelButtonLabel),
                Text(apple.cancelButtonLabel),
                Text(material.formatMediumDate(date)),
                Text(apple.datePickerMediumDate(date)),
              ],
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('ཕྱིར་འཐེན།'), findsNWidgets(2));
    expect(
      tester.widgetList<Text>(find.byType(Text)).map((text) => text.data),
      [
        'ཕྱིར་འཐེན།',
        'ཕྱིར་འཐེན།',
        'ཟླ་༡ཚེས་15, ཕུར་བུ་',
        'ཟླ་༡ཚེས་15, ཕུར་བུ་',
      ],
    );
  });
}
