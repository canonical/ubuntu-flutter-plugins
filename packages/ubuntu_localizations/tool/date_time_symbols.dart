import 'dart:io';

import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

void main(List<String> arguments) {
  final file = File(arguments.firstOrNull ?? '');
  if (arguments.length != 1 || !file.existsSync()) {
    stderr.write('''
Usage: dart run date_time_symbols.dart [/path/to/cldr/common/main/<locale>.xml]

Reads the given CLDR file and prints the date and time symbols.
''');
    exit(1);
  }

  final xml = XmlDocument.parse(file.readAsStringSync());
  final calendar = xml
      .findAllElements('calendar')
      .singleWhere((calendar) => calendar.getAttribute('type') == 'gregorian');

  String formatArray(Iterable<String> array) {
    return '[${array.join(', ')}]';
  }

  void printVariable(String variable, String Function() value) {
    try {
      stdout.write('$variable: ${value()},\n');
    } on StateError {
      stdout.write('// TODO: $variable\n');
    }
  }

  void printArray(String variable, Iterable<String> Function() array) {
    printVariable(variable, () => formatArray(array()));
  }

  Iterable<String> getEras(String context) {
    final eras = calendar
        .findAllElements(context)
        .single
        .findAllElements('era')
        .where((era) => era.getAttribute('alt') != 'variant')
        .map((era) => '\'${era.innerText}\'');
    if (eras.isNotEmpty) return eras;
    return calendar
        .findAllElements(context)
        .single
        .findAllElements('era')
        .map((era) => '\'${era.innerText}\'');
  }

  printArray('ERAS', () => getEras('eraAbbr'));
  printArray('NARROWERAS', () => getEras('eraNarrow'));
  printArray('ERANAMES', () => getEras('eraNames'));

  Iterable<String> getMonths(String context, String width) {
    return calendar
        .findAllElements('monthContext')
        .singleWhere((e) => e.getAttribute('type') == context)
        .findAllElements('monthWidth')
        .singleWhere((e) => e.getAttribute('type') == width)
        .findAllElements('month')
        .map((month) => '\'${month.innerText}\'');
  }

  printArray('NARROWMONTHS', () => getMonths('format', 'narrow'));
  printArray(
    'STANDALONENARROWMONTHS',
    () => getMonths('stand-alone', 'narrow'),
  );
  printArray('MONTHS', () => getMonths('format', 'wide'));
  printArray('STANDALONEMONTHS', () => getMonths('stand-alone', 'wide'));
  printArray('SHORTMONTHS', () => getMonths('format', 'abbreviated'));
  printArray(
    'STANDALONESHORTMONTHS',
    () => getMonths('stand-alone', 'abbreviated'),
  );

  Iterable<String> getDays(String context, String width) {
    return calendar
        .findAllElements('dayContext')
        .singleWhere((e) => e.getAttribute('type') == context)
        .findAllElements('dayWidth')
        .singleWhere((e) => e.getAttribute('type') == width)
        .findAllElements('day')
        .map((day) => '\'${day.innerText}\'');
  }

  printArray('WEEKDAYS', () => getDays('format', 'wide'));
  printArray('STANDALONEWEEKDAYS', () => getDays('stand-alone', 'wide'));
  printArray('SHORTWEEKDAYS', () => getDays('format', 'abbreviated'));
  printArray(
    'STANDALONESHORTWEEKDAYS',
    () => getDays('stand-alone', 'abbreviated'),
  );
  printArray('NARROWWEEKDAYS', () => getDays('format', 'narrow'));
  printArray(
    'STANDALONENARROWWEEKDAYS',
    () => getDays('stand-alone', 'narrow'),
  );

  Iterable<String> getQuarters(String context, String width) {
    return calendar
        .findAllElements('quarterContext')
        .singleWhere((e) => e.getAttribute('type') == context)
        .findAllElements('quarterWidth')
        .singleWhere((e) => e.getAttribute('type') == width)
        .findAllElements('quarter')
        .map((quarter) => '\'${quarter.innerText}\'');
  }

  printArray('SHORTQUARTERS', () => getQuarters('format', 'abbreviated'));
  printArray('QUARTERS', () => getQuarters('format', 'wide'));

  Iterable<String> getAmPm(String context, String width) {
    return calendar
        .findAllElements('dayPeriodContext')
        .singleWhere((e) => e.getAttribute('type') == context)
        .findAllElements('dayPeriodWidth')
        .singleWhere((e) => e.getAttribute('type') == width)
        .findAllElements('dayPeriod')
        .where(
          (e) =>
              e.getAttribute('type') == 'am' || e.getAttribute('type') == 'pm',
        )
        .map((quarter) => '\'${quarter.innerText}\'');
  }

  printArray('AMPMS', () => getAmPm('format', 'abbreviated'));

  Iterable<String> getPatterns(String context) {
    return calendar
        .findAllElements(context)
        .map(
          (format) => format
              .findAllElements('pattern')
              .singleWhere(
                  (pattern) => pattern.getAttribute('alt') != 'variant',)
              .innerText
              .replaceAll('\'', '\\\''),
        )
        .map((pattern) => '\'$pattern\'');
  }

  printArray('DATEFORMATS', () => getPatterns('dateFormat'));
  printArray('TIMEFORMATS', () => getPatterns('timeFormat'));
  printArray('DATETIMEFORMATS', () => getPatterns('dateTimeFormat'));

  stdout.write('// TODO: see cldr/common/supplemental/supplementalData.xml\n');
  stdout.write('// FIRSTDAYOFWEEK: 0,\n');
  stdout.write('// WEEKENDRANGE: [5, 6],\n');
  stdout.write('// FIRSTWEEKCUTOFFDAY: 0, /* N/A */\n');
}
