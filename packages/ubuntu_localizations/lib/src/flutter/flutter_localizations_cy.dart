import 'dart:ui';

import 'flutter_localizations.dart';

class FlutterLocalizationsDelegateCy<T>
    extends FlutterLocalizationsDelegate<T> {
  const FlutterLocalizationsDelegateCy();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'cy';
}
