import 'dart:io';

import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

void main(List<String> arguments) {
  final file = File(arguments.firstOrNull ?? '');
  if (arguments.length != 1 || !file.existsSync()) {
    stderr.write('''
Usage: dart run date_time_patterns.dart [/path/to/cldr/common/main/<locale>.xml]

Reads the given CLDR file and prints the date and time patterns.
''');
    exit(1);
  }

  final xml = XmlDocument.parse(file.readAsStringSync());
  final calendar = xml
      .findAllElements('calendar')
      .singleWhere((calendar) => calendar.getAttribute('type') == 'gregorian');

  calendar.findAllElements('dateFormatItem').forEach((format) {
    final id = format.getAttribute('id');
    final dateFormat = format.text.replaceAll('\'', '\\\'');
    stdout.write('\'$id\': \'$dateFormat\',\n');
  });
}
