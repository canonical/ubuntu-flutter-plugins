import 'dart:ui';

import 'package:intl/date_symbols.dart';

import 'flutter_localizations.dart';

class FlutterLocalizationsDelegateBo<T>
    extends FlutterLocalizationsDelegate<T> {
  const FlutterLocalizationsDelegateBo();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'bo';

  @override
  DateSymbols get dateTimeSymbols => boDateTimeSymbols;

  @override
  Map<String, String>? get dateTimePatterns => boDateTimePatterns;
}

final boDateTimeSymbols = DateSymbols(
  NAME: 'bo',
  ERAS: ['སྤྱི་ལོ་སྔོན་', 'སྤྱི་ལོ་'],
  ERANAMES: ['སྤྱི་ལོ་སྔོན་', 'སྤྱི་ལོ་'],
  NARROWMONTHS: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'],
  STANDALONENARROWMONTHS: [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ],
  MONTHS: [
    'ཟླ་བ་དང་པོ',
    'ཟླ་བ་གཉིས་པ',
    'ཟླ་བ་གསུམ་པ',
    'ཟླ་བ་བཞི་པ',
    'ཟླ་བ་ལྔ་པ',
    'ཟླ་བ་དྲུག་པ',
    'ཟླ་བ་བདུན་པ',
    'ཟླ་བ་བརྒྱད་པ',
    'ཟླ་བ་དགུ་པ',
    'ཟླ་བ་བཅུ་པ',
    'ཟླ་བ་བཅུ་གཅིག་པ',
    'ཟླ་བ་བཅུ་གཉིས་པ',
  ],
  STANDALONEMONTHS: [
    'ཟླ་བ་དང་པོ་',
    'ཟླ་བ་གཉིས་པ་',
    'ཟླ་བ་གསུམ་པ་',
    'ཟླ་བ་བཞི་པ་',
    'ཟླ་བ་ལྔ་པ་',
    'ཟླ་བ་དྲུག་པ་',
    'ཟླ་བ་བདུན་པ་',
    'ཟླ་བ་བརྒྱད་པ་',
    'ཟླ་བ་དགུ་པ་',
    'ཟླ་བ་བཅུ་པ་',
    'ཟླ་བ་བཅུ་གཅིག་པ་',
    'ཟླ་བ་བཅུ་གཉིས་པ་',
  ],
  SHORTMONTHS: [
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
    'གཟའ་ཉི་མ་',
    'གཟའ་ཟླ་བ་',
    'གཟའ་མིག་དམར་',
    'གཟའ་ལྷག་པ་',
    'གཟའ་ཕུར་བུ་',
    'གཟའ་པ་སངས་',
    'གཟའ་སྤེན་པ་',
  ],
  STANDALONEWEEKDAYS: [
    'གཟའ་ཉི་མ་',
    'གཟའ་ཟླ་བ་',
    'གཟའ་མིག་དམར་',
    'གཟའ་ལྷག་པ་',
    'གཟའ་ཕུར་བུ་',
    'གཟའ་པ་སངས་',
    'གཟའ་སྤེན་པ་',
  ],
  SHORTWEEKDAYS: [
    'ཉི་མ་',
    'ཟླ་བ་',
    'མིག་དམར་',
    'ལྷག་པ་',
    'ཕུར་བུ་',
    'པ་སངས་',
    'སྤེན་པ་',
  ],
  STANDALONESHORTWEEKDAYS: [
    'ཉི་མ་',
    'ཟླ་བ་',
    'མིག་དམར་',
    'ལྷག་པ་',
    'ཕུར་བུ་',
    'པ་སངས་',
    'སྤེན་པ་',
  ],
  NARROWWEEKDAYS: ['ཉི', 'ཟླ', 'མིག', 'ལྷག', 'ཕུར', 'སངས', 'སྤེན'],
  STANDALONENARROWWEEKDAYS: ['ཉི', 'ཟླ', 'མིག', 'ལྷག', 'ཕུར', 'སངས', 'སྤེན'],
  SHORTQUARTERS: [
    'དུས་ཚིགས་དང་པོ།',
    'དུས་ཚིགས་གཉིས་པ།',
    'དུས་ཚིགས་གསུམ་པ།',
    'དུས་ཚིགས་བཞི་པ།',
  ],
  QUARTERS: [
    'དུས་ཚིགས་དང་པོ།',
    'དུས་ཚིགས་གཉིས་པ།',
    'དུས་ཚིགས་གསུམ་པ།',
    'དུས་ཚིགས་བཞི་པ།',
  ],
  AMPMS: ['སྔ་དྲོ་', 'ཕྱི་དྲོ་'],
  DATEFORMATS: [
    'y MMMMའི་ཚེས་d, EEEE',
    'སྤྱི་ལོ་y MMMMའི་ཚེས་d',
    'y ལོའི་MMMཚེས་d',
    'y-MM-dd',
  ],
  TIMEFORMATS: ['HH:mm:ss zzzz', 'HH:mm:ss z', 'HH:mm:ss', 'HH:mm'],
  DATETIMEFORMATS: [],
  FIRSTDAYOFWEEK: 6,
  WEEKENDRANGE: const [5, 6],
  FIRSTWEEKCUTOFFDAY: 0, /* N/A */
);

const boDateTimePatterns = {
  'GyMMM': 'G y LLLL',
  'MMMd': 'MMMཚེས་d',
  'MMMEd': 'MMMཚེས་d, E',
  'MMMMd': 'MMMMའི་ཚེས་d',
  'yMMM': 'y LLL',
  'yMMMd': 'y ལོའི་MMMཚེས་d',
  'yMMMMd': 'སྤྱི་ལོ་y MMMMའི་ཚེས་d',
};
