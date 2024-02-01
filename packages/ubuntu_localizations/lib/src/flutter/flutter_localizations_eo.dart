import 'dart:ui';

import 'package:intl/date_symbols.dart';

import 'package:ubuntu_localizations/src/flutter/flutter_localizations.dart';

class FlutterLocalizationsDelegateEo<T>
    extends FlutterLocalizationsDelegate<T> {
  const FlutterLocalizationsDelegateEo();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'eo';

  @override
  DateSymbols get dateTimeSymbols => eoDateTimeSymbols;

  @override
  Map<String, String>? get dateTimePatterns => eoDateTimePatterns;
}

final eoDateTimeSymbols = DateSymbols(
  NAME: 'eo',
  ERAS: ['aK', 'pK'],
  ERANAMES: ['aK', 'pK'],
  NARROWMONTHS: ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'],
  STANDALONENARROWMONTHS: [
    'J',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D',
  ],
  MONTHS: [
    'januaro',
    'februaro',
    'marto',
    'aprilo',
    'majo',
    'junio',
    'julio',
    'aŭgusto',
    'septembro',
    'oktobro',
    'novembro',
    'decembro',
  ],
  STANDALONEMONTHS: [
    'januaro',
    'februaro',
    'marto',
    'aprilo',
    'majo',
    'junio',
    'julio',
    'aŭgusto',
    'septembro',
    'oktobro',
    'novembro',
    'decembro',
  ],
  SHORTMONTHS: [
    'jan',
    'feb',
    'mar',
    'apr',
    'maj',
    'jun',
    'jul',
    'aŭg',
    'sep',
    'okt',
    'nov',
    'dec',
  ],
  STANDALONESHORTMONTHS: [
    'jan',
    'feb',
    'mar',
    'apr',
    'maj',
    'jun',
    'jul',
    'aŭg',
    'sep',
    'okt',
    'nov',
    'dec',
  ],
  WEEKDAYS: [
    'dimanĉo',
    'lundo',
    'mardo',
    'merkredo',
    'ĵaŭdo',
    'vendredo',
    'sabato',
  ],
  STANDALONEWEEKDAYS: [
    'dimanĉo',
    'lundo',
    'mardo',
    'merkredo',
    'ĵaŭdo',
    'vendredo',
    'sabato',
  ],
  SHORTWEEKDAYS: ['di', 'lu', 'ma', 'me', 'ĵa', 've', 'sa'],
  STANDALONESHORTWEEKDAYS: ['di', 'lu', 'ma', 'me', 'ĵa', 've', 'sa'],
  NARROWWEEKDAYS: ['D', 'L', 'M', 'M', 'Ĵ', 'V', 'S'],
  STANDALONENARROWWEEKDAYS: ['D', 'L', 'M', 'M', 'Ĵ', 'V', 'S'],
  SHORTQUARTERS: ['K1', 'K2', 'K3', 'K4'],
  QUARTERS: [
    '1-a kvaronjaro',
    '2-a kvaronjaro',
    '3-a kvaronjaro',
    '4-a kvaronjaro',
  ],
  AMPMS: ['atm', 'ptm'],
  DATEFORMATS: [
    'EEEE, d-\'a\' \'de\' MMMM y',
    'y-MMMM-dd',
    'y-MMM-dd',
    'yy-MM-dd',
  ],
  TIMEFORMATS: [
    'H-\'a\' \'horo\' \'kaj\' m:ss zzzz',
    'HH:mm:ss z',
    'HH:mm:ss',
    'HH:mm',
  ],
  DATETIMEFORMATS: [],
  FIRSTDAYOFWEEK: 0,
  WEEKENDRANGE: [5, 6],
  FIRSTWEEKCUTOFFDAY: 0, /* N/A */
);

const eoDateTimePatterns = {
  'd': 'd',
  'Ed': 'E d',
  'MMMd': 'd MMM',
  'MMMEd': 'E \'la\' d-\'an\' \'de\' MMM',
  'y': 'y',
  'yMMM': 'MMM y',
  'yMMMd': 'd MMM y',
  'yMMMEd': 'E \'la\' d-\'an\' \'de\' MMM y',
  'yQQQ': 'QQQ y',
  'yQQQQ': 'QQQQ y',
};
