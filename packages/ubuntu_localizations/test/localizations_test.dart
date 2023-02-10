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
        () async => await delegate.load(locale),
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
        () async => await delegate.load(locale),
        returnsNormally,
        reason:
            'CupertinoLocalizations failed to load "$locale". Missing date time patters/symbols?',
      );
    }
  });
}
