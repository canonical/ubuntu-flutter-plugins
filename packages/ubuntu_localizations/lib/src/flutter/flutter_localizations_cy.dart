import 'dart:ui';

import 'package:ubuntu_localizations/src/flutter/flutter_localizations.dart';

class FlutterLocalizationsDelegateCy<T>
    extends FlutterLocalizationsDelegate<T> {
  const FlutterLocalizationsDelegateCy();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'cy';
}
