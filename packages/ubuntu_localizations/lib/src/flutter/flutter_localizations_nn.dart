import 'dart:ui';

import 'package:intl/date_symbols.dart';

import 'flutter_localizations.dart';

class FlutterLocalizationsDelegateNn<T>
    extends FlutterLocalizationsDelegate<T> {
  const FlutterLocalizationsDelegateNn();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'nn';

  @override
  String? get baseLocaleName => 'nb';

  @override
  DateSymbols get dateTimeSymbols => nnDateTimeSymbols;

  @override
  Map<String, String>? get dateTimePatterns => nnDateTimePatterns;
}

final nnDateTimeSymbols = DateSymbols(
  NAME: 'nn',
  ERAS: ['fvt', 'vt'],
  ERANAMES: ['før vår tidsrekning', 'etter vår tidsrekning'],
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
    'januar',
    'februar',
    'mars',
    'april',
    'mai',
    'juni',
    'juli',
    'august',
    'september',
    'oktober',
    'november',
    'desember',
  ],
  STANDALONEMONTHS: [
    'januar',
    'februar',
    'mars',
    'april',
    'mai',
    'juni',
    'juli',
    'august',
    'september',
    'oktober',
    'november',
    'desember',
  ],
  SHORTMONTHS: [
    'jan.',
    'feb.',
    'mars',
    'apr.',
    'mai',
    'juni',
    'juli',
    'aug.',
    'sep.',
    'okt.',
    'nov.',
    'des.',
  ],
  STANDALONESHORTMONTHS: [
    'jan',
    'feb',
    'mar',
    'apr',
    'mai',
    'jun',
    'jul',
    'aug',
    'sep',
    'okt',
    'nov',
    'des',
  ],
  WEEKDAYS: [
    'søndag',
    'måndag',
    'tysdag',
    'onsdag',
    'torsdag',
    'fredag',
    'laurdag',
  ],
  STANDALONEWEEKDAYS: [
    'søndag',
    'måndag',
    'tysdag',
    'onsdag',
    'torsdag',
    'fredag',
    'laurdag',
  ],
  SHORTWEEKDAYS: ['sø.', 'må.', 'ty.', 'on.', 'to.', 'fr.', 'la.'],
  STANDALONESHORTWEEKDAYS: ['søn', 'mån', 'tys', 'ons', 'tor', 'fre', 'lau'],
  NARROWWEEKDAYS: ['S', 'M', 'T', 'O', 'T', 'F', 'L'],
  STANDALONENARROWWEEKDAYS: ['S', 'M', 'T', 'O', 'T', 'F', 'L'],
  SHORTQUARTERS: ['K1', 'K2', 'K3', 'K4'],
  QUARTERS: ['1. kvartal', '2. kvartal', '3. kvartal', '4. kvartal'],
  AMPMS: ['f.m.', 'e.m.'],
  DATEFORMATS: ['EEEE d. MMMM y', 'd. MMMM y', 'd. MMM y', 'dd.MM.y'],
  TIMEFORMATS: ['\'kl\'. HH:mm:ss zzzz', 'HH:mm:ss z', 'HH:mm:ss', 'HH:mm'],
  DATETIMEFORMATS: ['{1} {0}', '{1} \'kl\'. {0}', '{1}, {0}', '{1}, {0}'],
  FIRSTDAYOFWEEK: 0,
  WEEKENDRANGE: [5, 6],
  FIRSTWEEKCUTOFFDAY: 0, /* N/A */
);

const nnDateTimePatterns = {
  'Bh': 'h B',
  'Bhm': 'h:mm B',
  'Bhms': 'h:mm:ss B',
  'd': 'd.',
  'E': 'ccc',
  'EBhm': 'E h:mm B',
  'EBhms': 'E h:mm:ss B',
  'Ed': 'E d.',
  'Ehm': 'E h:mm a',
  'EHm': 'E \'kl\'. HH:mm',
  'Ehms': 'E h:mm:ss a',
  'EHms': 'E \'kl\'. HH:mm:ss',
  'Gy': 'y G',
  'GyMd': 'dd.MM.y GGGGG',
  'GyMMM': 'MMM y G',
  'GyMMMd': 'd. MMM y G',
  'GyMMMEd': 'E d. MMM y G',
  'h': 'h a',
  'H': 'HH',
  'hm': 'h:mm a',
  'Hm': 'HH:mm',
  'hms': 'h:mm:ss a',
  'Hms': 'HH:mm:ss',
  'hmsv': 'h:mm:ss a v',
  'Hmsv': 'HH:mm:ss v',
  'hmv': 'h:mm a v',
  'Hmv': 'HH:mm v',
  'M': 'L.',
  'Md': 'd.M.',
  'MEd': 'E d.M.',
  'MMdd': 'd.M.',
  'MMM': 'LLL',
  'MMMd': 'd. MMM',
  'MMMEd': 'E d. MMM',
  'MMMMd': 'd. MMMM',
  'MMMMW': '\'den\' W. \'uken\' \'i\' MMMM',
  'ms': 'mm:ss',
  'y': 'y',
  'yM': 'M.y',
  'yMd': 'd.M.y',
  'yMEd': 'E d.M.y',
  'yMM': 'MM.y',
  'yMMM': 'MMM y',
  'yMMMd': 'd. MMM y',
  'yMMMEd': 'E d. MMM y',
  'yMMMM': 'MMMM y',
  'yQQQ': 'QQQ y',
  'yQQQQ': 'QQQQ y',
  'yw': '\'uke\' w \'i\' Y',
};
