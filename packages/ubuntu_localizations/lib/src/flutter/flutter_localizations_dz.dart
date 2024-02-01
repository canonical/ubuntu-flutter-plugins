import 'dart:ui';

import 'package:intl/date_symbols.dart';

import 'package:ubuntu_localizations/src/flutter/flutter_localizations.dart';

class FlutterLocalizationsDelegateDz<T>
    extends FlutterLocalizationsDelegate<T> {
  const FlutterLocalizationsDelegateDz();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'dz';

  @override
  DateSymbols get dateTimeSymbols => dzDateTimeSymbols;

  @override
  Map<String, String>? get dateTimePatterns => dzDateTimePatterns;
}

final dzDateTimeSymbols = DateSymbols(
  NAME: 'dz',
  ERAS: ['BCE', 'CE'],
  ERANAMES: ['BCE', 'CE'],
  NARROWMONTHS: ['༡', '༢', '༣', '4', '༥', '༦', '༧', '༨', '9', '༡༠', '༡༡', '༡༢'],
  STANDALONENARROWMONTHS: [
    '༡',
    '༢',
    '༣',
    '༤',
    '༥',
    '༦',
    '༧',
    '༨',
    '༩',
    '༡༠',
    '༡༡',
    '༡༢',
  ],
  MONTHS: [
    'ཟླ་དངཔ་',
    'ཟླ་གཉིས་པ་',
    'ཟླ་གསུམ་པ་',
    'ཟླ་བཞི་པ་',
    'ཟླ་ལྔ་པ་',
    'ཟླ་དྲུག་པ',
    'ཟླ་བདུན་པ་',
    'ཟླ་བརྒྱད་པ་',
    'ཟླ་དགུ་པ་',
    'ཟླ་བཅུ་པ་',
    'ཟླ་བཅུ་གཅིག་པ་',
    'ཟླ་བཅུ་གཉིས་པ་',
  ],
  STANDALONEMONTHS: [
    'སྤྱི་ཟླ་དངཔ་',
    'སྤྱི་ཟླ་གཉིས་པ་',
    'སྤྱི་ཟླ་གསུམ་པ་',
    'སྤྱི་ཟླ་བཞི་པ',
    'སྤྱི་ཟླ་ལྔ་པ་',
    'སྤྱི་ཟླ་དྲུག་པ',
    'སྤྱི་ཟླ་བདུན་པ་',
    'སྤྱི་ཟླ་བརྒྱད་པ་',
    'སྤྱི་ཟླ་དགུ་པ་',
    'སྤྱི་ཟླ་བཅུ་པ་',
    'སྤྱི་ཟླ་བཅུ་གཅིག་པ་',
    'སྤྱི་ཟླ་བཅུ་གཉིས་པ་',
  ],
  SHORTMONTHS: ['༡', '༢', '༣', '༤', '༥', '༦', '༧', '༨', '༩', '༡༠', '༡༡', '12'],
  STANDALONESHORTMONTHS: [
    'ཟླ་༡',
    'ཟླ་༢',
    'ཟླ་༣',
    'ཟླ་༤',
    'ཟླ་༥',
    'ཟླ་༦',
    'ཟླ་༧',
    'ཟླ་༨',
    'ཟླ་༩',
    'ཟླ་༡༠',
    'ཟླ་༡༡',
    'ཟླ་༡༢',
  ],
  WEEKDAYS: [
    'གཟའ་ཟླ་བ་',
    'གཟའ་མིག་དམར་',
    'གཟའ་ལྷག་པ་',
    'གཟའ་ཕུར་བུ་',
    'གཟའ་པ་སངས་',
    'གཟའ་སྤེན་པ་',
    'གཟའ་ཉི་མ་',
  ],
  STANDALONEWEEKDAYS: [
    'གཟའ་ཟླ་བ་',
    'གཟའ་མིག་དམར་',
    'གཟའ་ལྷག་པ་',
    'གཟའ་ཕུར་བུ་',
    'གཟའ་པ་སངས་',
    'གཟའ་སྤེན་པ་',
    'གཟའ་ཉི་མ་',
  ],
  SHORTWEEKDAYS: ['ཟླ་', 'མིར་', 'ལྷག་', 'ཕུར་', 'སངས་', 'སྤེན་', 'ཉི་'],
  STANDALONESHORTWEEKDAYS: [
    'ཟླ་',
    'མིར་',
    'ལྷག་',
    'ཕུར་',
    'སངས་',
    'སྤེན་',
    'ཉི་',
  ],
  NARROWWEEKDAYS: ['ཟླ', 'མིར', 'ལྷག', 'ཕུར', 'སངྶ', 'སྤེན', 'ཉི'],
  STANDALONENARROWWEEKDAYS: ['ཟླ', 'མིར', 'ལྷག', 'ཕུར', 'སངྶ', 'སྤེན', 'ཉི'],
  SHORTQUARTERS: ['བཞི་དཔྱ་༡', 'བཞི་དཔྱ་༢', 'བཞི་དཔྱ་༣', 'བཞི་དཔྱ་༤'],
  QUARTERS: [
    'བཞི་དཔྱ་དང་པ་',
    'བཞི་དཔྱ་གཉིས་པ་',
    'བཞི་དཔྱ་གསུམ་པ་',
    'བཞི་དཔྱ་བཞི་པ་',
  ],
  AMPMS: ['སྔ་ཆ་', 'ཕྱི་ཆ་'],
  DATEFORMATS: [
    'EEEE, སྤྱི་ལོ་y MMMM ཚེས་dd',
    'སྤྱི་ལོ་y MMMM ཚེས་ dd',
    'སྤྱི་ལོ་y ཟླ་MMM ཚེས་dd',
    'y-MM-dd',
  ],
  TIMEFORMATS: [
    'ཆུ་ཚོད་ h སྐར་མ་ mm:ss a zzzz',
    'ཆུ་ཚོད་ h སྐར་མ་ mm:ss a z',
    'ཆུ་ཚོད་h:mm:ss a',
    'ཆུ་ཚོད་ h སྐར་མ་ mm a',
  ],
  DATETIMEFORMATS: ['{1} {0}', '{1} {0}', '{1} {0}', '{1} {0}'],
  FIRSTDAYOFWEEK: 6,
  WEEKENDRANGE: [5, 6],
  FIRSTWEEKCUTOFFDAY: 0, /* N/A */
);

const dzDateTimePatterns = {
  'd': 'd',
  'Ed': 'd E',
  'Gy': 'G y',
  'GyMMM': 'G y སྤྱི་ཟླ་MMM',
  'GyMMMd': 'G y MMM d',
  'GyMMMEd': 'གཟའ་E, G ལོy ཟླ་MMM ཚེ་d',
  'h': 'ཆུ་ཚོད་h a',
  'H': 'ཆུ་ཚོད་HH',
  'hm': 'h:mm a',
  'Hm': 'HH:mm',
  'hms': 'h:mm:ss a',
  'Hms': 'HH:mm:ss',
  'M': 'L',
  'Md': 'M-d',
  'MEd': 'E, M-d',
  'MMM': 'སྤྱི་LLL',
  'MMMd': 'སྤྱི་LLL ཚེ་d',
  'MMMEd': 'E, སྤྱི་LLL ཚེ་d',
  'ms': 'mm:ss',
  'y': 'y',
  'yM': 'y-M',
  'yMd': 'y-M-d',
  'yMEd': 'E, y-M-d',
  'yMMM': 'y སྤྱི་ཟླ་MMM',
  'yMMMd': 'y MMM d',
  'yMMMEd': 'གཟའ་E, ལོy ཟླ་MMM ཚེ་d',
  'yQQQ': 'y QQQ',
  'yQQQQ': 'y QQQQ',
};
