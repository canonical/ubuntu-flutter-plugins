import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';

import 'flutter/flutter_localizations.dart';
import 'l10n/ubuntu_localizations.dart';

export 'l10n/ubuntu_localizations.dart';

/// Provides localization delegates.
class GlobalUbuntuLocalizations {
  /// The list of localization delegates.
  static const List<LocalizationsDelegate<dynamic>> delegates =
      <LocalizationsDelegate<dynamic>>[
    UbuntuLocalizations.delegate,
    ...FlutterMaterialLocalizations.delegates,
    ...FlutterCupertinoLocalizations.delegates,
  ];
}

/// Initializes [Intl.defaultLocale] for formatting dates, times, and numbers.
///
/// If [locale] is not specified, the system locale is used.
///
/// See also:
/// * [Intl.defaultLocale]
/// * [Intl.systemLocale]
Future<void> initDefaultLocale([String? locale]) async {
  Intl.defaultLocale = locale ?? await findSystemLocale();
}

/// A localized language and its locale.
@immutable
class LocalizedLanguage {
  /// Creates a localized language with the given [name] and [locale].
  const LocalizedLanguage(this.name, this.locale);

  /// A localized name of the language.
  final String name;

  /// The locale of the language.
  final Locale locale;

  @override
  String toString() => 'Language($name, $locale)';

  @override
  int get hashCode => Object.hash(name, locale);

  @override
  bool operator ==(dynamic other) =>
      other is LocalizedLanguage &&
      other.name == name &&
      other.locale == locale;
}

/// Builds a sorted list of localized languages.
///
/// [locales] must contain the base locale i.e. the template .arb locale.
Future<Iterable<LocalizedLanguage>> loadLocalizedLanguages(
    List<Locale> locales) async {
  final languages = SplayTreeMap<String, LocalizedLanguage>();
  for (final locale in locales) {
    final localization = await UbuntuLocalizations.delegate.load(locale);
    if (localization.languageName.isNotEmpty) {
      final fullLocale = Locale(
        locale.languageCode,
        locale.countryCode ?? localization.countryCode,
      );
      final key = removeDiacritics(localization.languageName);
      languages[key] = LocalizedLanguage(localization.languageName, fullLocale);
    }
  }
  return languages.values;
}

// A fallback locale that must always exist (same as the template .arb).
const _kBaseLocale = Locale('en', 'US');

/// A helper to match locales.
extension LocalizedLanguageMatcher on List<LocalizedLanguage> {
  /// Returns the index of the best match for the given [locale] or falls back
  /// to the base locale if the given locale is not found.
  ///
  /// The best matching locale is determined by the following rules:
  ///
  /// - Full match (language + country + script)
  /// - Matching language and country
  /// - Matching language
  /// - Fall back to the base locale i.e. the template .arb locale.
  int findBestMatch(Locale locale) {
    return _indexOfLocaleOrNull(locale) ??
        _indexOfNeutralLocaleOrNull(locale) ??
        _indexOfParentLocaleOrNull(locale) ??
        _indexOfLocaleOrNull(_kBaseLocale)!;
  }

  // full match (language, country, and script)
  int? _indexOfLocaleOrNull(Locale locale) {
    final index = indexWhere((lang) => lang.locale == locale);
    return index != -1 ? index : null;
  }

  // match language and country
  int? _indexOfNeutralLocaleOrNull(Locale locale) {
    final index = indexWhere((lang) => lang.locale == locale.neutral);
    return index != -1 ? index : null;
  }

  // match language only
  int? _indexOfParentLocaleOrNull(Locale locale) {
    final index = indexWhere((lang) => lang.locale == locale.parent);
    return index != -1 ? index : null;
  }
}

extension _LocaleExtension on Locale {
  // not associated to any specific country
  Locale get parent => Locale(languageCode);

  // not associated to any specific script
  Locale get neutral => Locale(languageCode, countryCode);
}

/// Parses the given locale string and returns a corresponding [Locale] object.
///
/// The standard format is `language[_territory][.codeset][@modifier]`, but this
/// parser tries to be as relaxed as possible by allowing the parts to be in an
/// arbitrary order.
///
/// Language and country/territory codes are detected by matching against the
/// following rules:
///
/// - language code is 2-3 lowercase letters (ISO 639)
/// - country code is 2-3 uppercase letters (ISO 3166)
///
/// Codeset and modifier are ignored.
Locale parseLocale(String locale) {
  final codes = locale
      .split(RegExp(r'[_\.@]'))
      .where((code) => code.length == 2 || code.length == 3);

  final language = codes.firstWhereOrNull((code) => code == code.toLowerCase());
  final country = codes.firstWhereOrNull((code) => code == code.toUpperCase());

  return Locale(language ?? 'C', country);
}
