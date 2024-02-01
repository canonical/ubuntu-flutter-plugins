import 'dart:ui';

import 'package:ubuntu_localizations/src/flutter/flutter_localizations.dart';

class FlutterLocalizationsDelegateGa<T>
    extends FlutterLocalizationsDelegate<T> {
  const FlutterLocalizationsDelegateGa();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ga';
}
