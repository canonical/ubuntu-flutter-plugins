import 'dart:ui';

import 'package:intl/date_symbols.dart';

import 'flutter_localizations.dart';

class FlutterLocalizationsDelegateTg<T>
    extends FlutterLocalizationsDelegate<T> {
  const FlutterLocalizationsDelegateTg();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tg';

  @override
  DateSymbols get dateTimeSymbols => tgDateTimeSymbols;

  @override
  Map<String, String>? get dateTimePatterns => tgDateTimePatterns;
}

final tgDateTimeSymbols = DateSymbols(
  NAME: 'tg',
  ERAS: ['ПеМ', 'ПаМ'],
  ERANAMES: ['Пеш аз милод', 'Пас аз милод'],
  NARROWMONTHS: ['Я', 'Ф', 'М', 'А', 'М', 'И', 'И', 'А', 'С', 'О', 'Н', 'Д'],
  STANDALONENARROWMONTHS: [
    'Я',
    'Ф',
    'М',
    'А',
    'М',
    'И',
    'И',
    'А',
    'С',
    'О',
    'Н',
    'Д',
  ],
  MONTHS: [
    'Январ',
    'Феврал',
    'Март',
    'Апрел',
    'Май',
    'Июн',
    'Июл',
    'Август',
    'Сентябр',
    'Октябр',
    'Ноябр',
    'Декабр',
  ],
  STANDALONEMONTHS: [
    'Январ',
    'Феврал',
    'Март',
    'Апрел',
    'Май',
    'Июн',
    'Июл',
    'Август',
    'Сентябр',
    'Октябр',
    'Ноябр',
    'Декабр',
  ],
  SHORTMONTHS: [
    'Янв',
    'Фев',
    'Мар',
    'Апр',
    'Май',
    'Июн',
    'Июл',
    'Авг',
    'Сен',
    'Окт',
    'Ноя',
    'Дек',
  ],
  STANDALONESHORTMONTHS: [
    'Янв',
    'Фев',
    'Мар',
    'Апр',
    'Май',
    'Июн',
    'Июл',
    'Авг',
    'Сен',
    'Окт',
    'Ноя',
    'Дек',
  ],
  WEEKDAYS: [
    'Якшанбе',
    'Душанбе',
    'Сешанбе',
    'Чоршанбе',
    'Панҷшанбе',
    'Ҷумъа',
    'Шанбе',
  ],
  STANDALONEWEEKDAYS: [
    'Якшанбе',
    'Душанбе',
    'Сешанбе',
    'Чоршанбе',
    'Панҷшанбе',
    'Ҷумъа',
    'Шанбе',
  ],
  SHORTWEEKDAYS: ['Яшб', 'Дшб', 'Сшб', 'Чшб', 'Пшб', 'Ҷмъ', 'Шнб'],
  STANDALONESHORTWEEKDAYS: ['Яшб', 'Дшб', 'Сшб', 'Чшб', 'Пшб', 'Ҷмъ', 'Шнб'],
  NARROWWEEKDAYS: ['Я', 'Д', 'С', 'Ч', 'П', 'Ҷ', 'Ш'],
  STANDALONENARROWWEEKDAYS: ['Я', 'Д', 'С', 'Ч', 'П', 'Ҷ', 'Ш'],
  SHORTQUARTERS: ['Ч1', 'Ч2', 'Ч3', 'Ч4'],
  QUARTERS: ['Ч1', 'Ч2', 'Ч3', 'Ч4'],
  AMPMS: ['AM', 'PM'],
  DATEFORMATS: ['EEEE, dd MMMM y', 'dd MMMM y', 'dd MMM y', 'dd/MM/yy'],
  TIMEFORMATS: ['HH:mm:ss zzzz', 'HH:mm:ss z', 'HH:mm:ss', 'HH:mm'],
  DATETIMEFORMATS: ['{1} {0}', '{1} {0}', '{1} {0}', '{1} {0}'],
  FIRSTDAYOFWEEK: 0,
  WEEKENDRANGE: [5, 6],
  FIRSTWEEKCUTOFFDAY: 0, /* N/A */
);

const tgDateTimePatterns = {
  'd': 'd',
  'E': 'ccc',
  'Ed': 'd, E',
  'Ehm': 'E h:mm a',
  'EHm': 'E HH:mm',
  'Ehms': 'E h:mm:ss a',
  'EHms': 'E HH:mm:ss',
  'Gy': 'G y',
  'GyMMM': 'G y MMM',
  'GyMMMd': 'G y MMM d',
  'GyMMMEd': 'G y MMM d, E',
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
  'M': 'L',
  'Md': 'MM-dd',
  'MEd': 'MM-dd, E',
  'MMM': 'LLL',
  'MMMd': 'MMM d',
  'MMMEd': 'MMM d, E',
  'MMMMd': 'MMMM d',
  'ms': 'mm:ss',
  'y': 'y',
  'yM': 'y-MM',
  'yMd': 'y-MM-dd',
  'yMEd': 'y-MM-dd, E',
  'yMMM': 'y MMM',
  'yMMMd': 'y MMM d',
  'yMMMEd': 'y MMM d, E',
  'yMMMM': 'y MMMM',
  'yQQQ': 'y QQQ',
  'yQQQQ': 'y QQQQ',
};
