import 'dart:ui';

import 'package:intl/date_symbols.dart';

import 'package:ubuntu_localizations/src/flutter/flutter_localizations.dart';

class FlutterLocalizationsDelegateKu<T>
    extends FlutterLocalizationsDelegate<T> {
  const FlutterLocalizationsDelegateKu();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  DateSymbols get dateTimeSymbols => kuDateTimeSymbols;

  @override
  Map<String, String>? get dateTimePatterns => kuDateTimePatterns;
}

final kuDateTimeSymbols = DateSymbols(
  NAME: 'ku',
  ERAS: ['BZ', 'PZ'],
  ERANAMES: ['berî zayînê', 'piştî zayînê'],
  NARROWMONTHS: ['R', 'R', 'A', 'A', 'G', 'P', 'T', 'G', 'R', 'K', 'S', 'B'],
  STANDALONENARROWMONTHS: [
    'R',
    'R',
    'A',
    'A',
    'G',
    'P',
    'T',
    'G',
    'R',
    'K',
    'S',
    'B',
  ],
  MONTHS: [
    'rêbendanê',
    'reşemiyê',
    'adarê',
    'avrêlê',
    'gulanê',
    'pûşperê',
    'tîrmehê',
    'gelawêjê',
    'rezberê',
    'kewçêrê',
    'sermawezê',
    'berfanbarê',
  ],
  STANDALONEMONTHS: [
    'rêbendan',
    'reşemî',
    'adar',
    'avrêl',
    'gulan',
    'pûşper',
    'tîrmeh',
    'gelawêj',
    'rezber',
    'kewçêr',
    'sermawez',
    'berfanbar',
  ],
  SHORTMONTHS: [
    'rêb',
    'reş',
    'ada',
    'avr',
    'gul',
    'pûş',
    'tîr',
    'gel',
    'rez',
    'kew',
    'ser',
    'ber',
  ],
  STANDALONESHORTMONTHS: [
    'rêb',
    'reş',
    'ada',
    'avr',
    'gul',
    'pûş',
    'tîr',
    'gel',
    'rez',
    'kew',
    'ser',
    'ber',
  ],
  WEEKDAYS: ['yekşem', 'duşem', 'sêşem', 'çarşem', 'pêncşem', 'în', 'şemî'],
  STANDALONEWEEKDAYS: [
    'yekşem',
    'duşem',
    'sêşem',
    'çarşem',
    'pêncşem',
    'în',
    'şemî',
  ],
  SHORTWEEKDAYS: ['yş', 'dş', 'sş', 'çş', 'pş', 'în', 'ş'],
  STANDALONESHORTWEEKDAYS: ['yş', 'dş', 'sş', 'çş', 'pş', 'în', 'ş'],
  NARROWWEEKDAYS: ['Y', 'D', 'S', 'Ç', 'P', 'Î', 'Ş'],
  STANDALONENARROWWEEKDAYS: ['Y', 'D', 'S', 'Ç', 'P', 'Î', 'Ş'],
  SHORTQUARTERS: ['Ç1', 'Ç2', 'Ç3', 'Ç4'],
  QUARTERS: ['Çarêka 1em', 'Çarêka 2em', 'Çarêka 3em', 'Çarêka 4em'],
  AMPMS: ['BN', 'PN'],
  DATEFORMATS: [],
  TIMEFORMATS: [],
  DATETIMEFORMATS: [],
  FIRSTDAYOFWEEK: 0,
  WEEKENDRANGE: [5, 6],
  FIRSTWEEKCUTOFFDAY: 0, /* N/A */
);

const kuDateTimePatterns = {
  'd': 'd',
  'E': 'ccc',
};
