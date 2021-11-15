import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_custom.dart' as intl;
import 'package:intl/date_symbol_data_local.dart' as intl;
import 'package:intl/date_time_patterns.dart' as intl;
import 'package:intl/date_symbols.dart';
import 'package:intl/intl.dart';

import 'material_localizations_cy.dart';
import 'material_localizations_ga.dart';
import 'material_localizations_nn.dart';
import 'material_localizations_oc.dart';

abstract class UbuntuMaterialLocalizations {
  static const List<LocalizationsDelegate<dynamic>> delegates =
      <LocalizationsDelegate<dynamic>>[
    UbuntuMaterialLocalizationsDelegateCy(),
    UbuntuMaterialLocalizationsDelegateGa(),
    UbuntuMaterialLocalizationsDelegateNn(),
    UbuntuMaterialLocalizationsDelegateOc(),
  ];
}

abstract class UbuntuMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const UbuntuMaterialLocalizationsDelegate();

  String? get baseLocaleName => null;
  DateSymbols? get dateTimeSymbols => null;
  Map<String, String>? get dateTimePatterns => null;

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    final String localeName = Intl.canonicalizedLocale(locale.toString());
    await intl.initializeDateFormatting();
    intl.initializeDateFormattingCustom(
      locale: localeName,
      patterns: dateTimePatterns ?? _inheritDateTimePatterns(localeName),
      symbols: dateTimeSymbols ?? _inheritDateTimeSymbols(localeName),
    );
    return SynchronousFuture<MaterialLocalizations>(
      MaterialLocalizationNb(
        localeName: localeName,
        fullYearFormat: DateFormat.y(localeName),
        compactDateFormat: DateFormat.yMd(localeName),
        shortDateFormat: DateFormat.yMMMd(localeName),
        mediumDateFormat: DateFormat.MMMEd(localeName),
        longDateFormat: DateFormat.yMMMMEEEEd(localeName),
        yearMonthFormat: DateFormat.yMMMM(localeName),
        shortMonthDayFormat: DateFormat.MMMd(localeName),
        decimalFormat: NumberFormat.decimalPattern(baseLocaleName ?? 'en_US'),
        twoDigitZeroPaddedFormat: NumberFormat('00', baseLocaleName ?? 'en_US'),
      ),
    );
  }

  DateSymbols _inheritDateTimeSymbols(String localeName) {
    final baseSymbols = intl.dateTimeSymbolMap()[baseLocaleName ?? localeName];
    final symbols = (baseSymbols as DateSymbols).serializeToMap();
    symbols['NAME'] = localeName;
    return DateSymbols.deserializeFromMap(symbols);
  }

  Map<String, String>? _inheritDateTimePatterns(String localeName) {
    return intl.dateTimePatternMap()[baseLocaleName ?? localeName];
  }

  @override
  bool shouldReload(UbuntuMaterialLocalizationsDelegate old) => false;
}
