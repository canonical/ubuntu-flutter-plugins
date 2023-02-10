import 'dart:ui';

import 'flutter_localizations.dart';

class FlutterLocalizationsDelegateOc<T>
    extends FlutterLocalizationsDelegate<T> {
  const FlutterLocalizationsDelegateOc();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'oc';

  @override
  String? get baseLocaleName => 'ca';
}
