import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_localizations/src/material/material_localizations.dart';
import 'package:ubuntu_localizations/ubuntu_localizations.dart';

// TODO: implement
const unsupportedLocales = ['ku'];

void main() {
  testWidgets('material supports all ubuntu localizations', (tester) async {
    final delegates = [
      GlobalMaterialLocalizations.delegate,
      ...UbuntuMaterialLocalizations.delegates,
    ];

    for (final locale in UbuntuLocalizations.supportedLocales) {
      // TODO: remove
      if (unsupportedLocales.contains(locale.languageCode)) continue;

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
}
