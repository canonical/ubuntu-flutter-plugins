import 'dart:ui';

import 'flutter_localizations.dart';

class FlutterLocalizationsDelegateGa<T>
    extends FlutterLocalizationsDelegate<T> {
  const FlutterLocalizationsDelegateGa();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ga';
}
