import 'dart:ui';

import 'package:ubuntu_localizations/src/flutter/flutter_localizations.dart';

class FlutterLocalizationsDelegateOc<T>
    extends FlutterLocalizationsDelegate<T> {
  const FlutterLocalizationsDelegateOc();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'oc';

  @override
  String? get baseLocaleName => 'ca';
}
