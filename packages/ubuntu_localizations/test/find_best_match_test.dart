import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_localizations/ubuntu_localizations.dart';

void main() {
  group('base locale present only as bare `en`', () {
    final languages = [
      const LocalizedLanguage('German', Locale('de', 'DE')),
      const LocalizedLanguage('English', Locale('en')),
      const LocalizedLanguage('English (UK)', Locale('en', 'GB')),
      const LocalizedLanguage('French', Locale('fr', 'FR')),
    ];

    test('bare en request matches the bare en entry exactly', () {
      final index = languages.findBestMatch(const Locale('en'));
      expect(languages[index].locale, const Locale('en'));
    });

    test('en_GB request matches en_GB exactly', () {
      final index = languages.findBestMatch(const Locale('en', 'GB'));
      expect(languages[index].locale, const Locale('en', 'GB'));
    });

    test('unknown en country (en_CA) resolves to bare en', () {
      final index = languages.findBestMatch(const Locale('en', 'CA'));
      expect(languages[index].locale, const Locale('en'));
    });

    test('unmatched locale falls back to the bare en entry', () {
      final index = languages.findBestMatch(const Locale('ja', 'JP'));
      expect(languages[index].locale, const Locale('en'));
    });
  });

  group('base locale present as explicit en_US', () {
    final languages = [
      const LocalizedLanguage('German', Locale('de', 'DE')),
      const LocalizedLanguage('English (UK)', Locale('en', 'GB')),
      const LocalizedLanguage('English (US)', Locale('en', 'US')),
      const LocalizedLanguage('French', Locale('fr', 'FR')),
    ];

    test('bare en request falls back to en_US, not en_GB', () {
      final index = languages.findBestMatch(const Locale('en'));
      expect(languages[index].locale, const Locale('en', 'US'));
    });

    test('en_US request matches en_US exactly', () {
      final index = languages.findBestMatch(const Locale('en', 'US'));
      expect(languages[index].locale, const Locale('en', 'US'));
    });

    test('en_GB request matches en_GB exactly', () {
      final index = languages.findBestMatch(const Locale('en', 'GB'));
      expect(languages[index].locale, const Locale('en', 'GB'));
    });

    test('unmatched locale falls back to en_US', () {
      final index = languages.findBestMatch(const Locale('ja', 'JP'));
      expect(languages[index].locale, const Locale('en', 'US'));
    });
  });

  test('bare en entry with a script code is not treated as the base locale',
      () {
    final languages = [
      const LocalizedLanguage(
        'English (Cyrillic)',
        Locale.fromSubtags(languageCode: 'en', scriptCode: 'Cyrl'),
      ),
    ];
    expect(
      () => languages.findBestMatch(const Locale('ja', 'JP')),
      throwsA(isA<TypeError>()),
    );
  });

  test('matching non-base language still uses generic parent', () {
    final languages = [
      const LocalizedLanguage('English', Locale('en', 'US')),
      const LocalizedLanguage('French', Locale('fr')),
    ];
    final index = languages.findBestMatch(const Locale('fr', 'CA'));
    expect(languages[index].locale, const Locale('fr'));
  });
}
