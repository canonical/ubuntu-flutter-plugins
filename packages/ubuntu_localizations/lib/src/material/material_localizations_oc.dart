import 'dart:ui';

import 'material_localizations.dart';

class UbuntuMaterialLocalizationsDelegateOc
    extends UbuntuMaterialLocalizationsDelegate {
  const UbuntuMaterialLocalizationsDelegateOc();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'oc';

  @override
  String? get baseLocaleName => 'ca';
}
