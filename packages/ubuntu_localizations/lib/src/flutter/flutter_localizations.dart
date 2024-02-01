import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_custom.dart' as intl;
import 'package:intl/date_symbol_data_local.dart' as intl;
import 'package:intl/date_symbols.dart';
import 'package:intl/date_time_patterns.dart' as intl;
import 'package:intl/intl.dart';

import 'package:ubuntu_localizations/src/flutter/flutter_localizations_bo.dart';
import 'package:ubuntu_localizations/src/flutter/flutter_localizations_cy.dart';
import 'package:ubuntu_localizations/src/flutter/flutter_localizations_dz.dart';
import 'package:ubuntu_localizations/src/flutter/flutter_localizations_eo.dart';
import 'package:ubuntu_localizations/src/flutter/flutter_localizations_ga.dart';
import 'package:ubuntu_localizations/src/flutter/flutter_localizations_ku.dart';
import 'package:ubuntu_localizations/src/flutter/flutter_localizations_nn.dart';
import 'package:ubuntu_localizations/src/flutter/flutter_localizations_oc.dart';
import 'package:ubuntu_localizations/src/flutter/flutter_localizations_se.dart';
import 'package:ubuntu_localizations/src/flutter/flutter_localizations_tg.dart';
import 'package:ubuntu_localizations/src/flutter/flutter_localizations_ug.dart';

abstract class FlutterMaterialLocalizations {
  static const List<LocalizationsDelegate<dynamic>> delegates =
      <LocalizationsDelegate<dynamic>>[
    FlutterLocalizationsDelegateBo<MaterialLocalizations>(),
    FlutterLocalizationsDelegateCy<MaterialLocalizations>(),
    FlutterLocalizationsDelegateDz<MaterialLocalizations>(),
    FlutterLocalizationsDelegateEo<MaterialLocalizations>(),
    FlutterLocalizationsDelegateGa<MaterialLocalizations>(),
    FlutterLocalizationsDelegateKu<MaterialLocalizations>(),
    FlutterLocalizationsDelegateNn<MaterialLocalizations>(),
    FlutterLocalizationsDelegateOc<MaterialLocalizations>(),
    FlutterLocalizationsDelegateSe<MaterialLocalizations>(),
    FlutterLocalizationsDelegateTg<MaterialLocalizations>(),
    FlutterLocalizationsDelegateUg<MaterialLocalizations>(),
  ];
}

abstract class FlutterCupertinoLocalizations {
  static const List<LocalizationsDelegate<dynamic>> delegates =
      <LocalizationsDelegate<dynamic>>[
    FlutterLocalizationsDelegateBo<CupertinoLocalizations>(),
    FlutterLocalizationsDelegateCy<CupertinoLocalizations>(),
    FlutterLocalizationsDelegateDz<CupertinoLocalizations>(),
    FlutterLocalizationsDelegateEo<CupertinoLocalizations>(),
    FlutterLocalizationsDelegateGa<CupertinoLocalizations>(),
    FlutterLocalizationsDelegateKu<CupertinoLocalizations>(),
    FlutterLocalizationsDelegateNn<CupertinoLocalizations>(),
    FlutterLocalizationsDelegateOc<CupertinoLocalizations>(),
    FlutterLocalizationsDelegateSe<CupertinoLocalizations>(),
    FlutterLocalizationsDelegateTg<CupertinoLocalizations>(),
    FlutterLocalizationsDelegateUg<CupertinoLocalizations>(),
  ];
}

typedef FlutterLocalizationsFactory<T> = T Function({
  required String localeName,
  required DateFormat fullYearFormat,
  required DateFormat compactDateFormat,
  required DateFormat shortDateFormat,
  required DateFormat mediumDateFormat,
  required DateFormat longDateFormat,
  required DateFormat yearMonthFormat,
  required DateFormat shortMonthDayFormat,
  required NumberFormat decimalFormat,
  NumberFormat? twoDigitZeroPaddedFormat,
});

abstract class FlutterLocalizationsDelegate<T>
    extends LocalizationsDelegate<T> {
  const FlutterLocalizationsDelegate();

  String? get baseLocaleName => null;
  DateSymbols? get dateTimeSymbols => null;
  Map<String, String>? get dateTimePatterns => null;

  @override
  Future<T> load(Locale locale) async {
    final localeName = Intl.canonicalizedLocale(locale.toString());
    await intl.initializeDateFormatting();
    intl.initializeDateFormattingCustom(
      locale: localeName,
      patterns: dateTimePatterns ?? _inheritDateTimePatterns(localeName),
      symbols: dateTimeSymbols ?? _inheritDateTimeSymbols(localeName),
    );

    switch (this) {
      case LocalizationsDelegate<MaterialLocalizations> _:
        return SynchronousFuture<T>(
          MaterialLocalizationNb(
            localeName: localeName,
            fullYearFormat: DateFormat.y(localeName),
            compactDateFormat: DateFormat.yMd(localeName),
            shortDateFormat: DateFormat.yMMMd(localeName),
            mediumDateFormat: DateFormat.MMMEd(localeName),
            longDateFormat: DateFormat.yMMMMEEEEd(localeName),
            yearMonthFormat: DateFormat.yMMMM(localeName),
            shortMonthDayFormat: DateFormat.MMMd(localeName),
            decimalFormat:
                NumberFormat.decimalPattern(baseLocaleName ?? 'en_US'),
            twoDigitZeroPaddedFormat:
                NumberFormat('00', baseLocaleName ?? 'en_US'),
          ) as T,
        );
      case LocalizationsDelegate<CupertinoLocalizations> _:
        return SynchronousFuture(
          CupertinoLocalizationNb(
            localeName: localeName,
            fullYearFormat: DateFormat.y(localeName),
            dayFormat: DateFormat.d(localeName),
            mediumDateFormat: DateFormat.MMMEd(localeName),
            singleDigitHourFormat: DateFormat('HH', localeName),
            singleDigitMinuteFormat: DateFormat.m(localeName),
            doubleDigitMinuteFormat: DateFormat('mm', localeName),
            singleDigitSecondFormat: DateFormat.s(localeName),
            decimalFormat:
                NumberFormat.decimalPattern(baseLocaleName ?? 'en_US'),
          ) as T,
        );
      default:
        throw UnsupportedError(T.runtimeType.toString());
    }
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
  bool shouldReload(FlutterLocalizationsDelegate<T> old) => false;
}
