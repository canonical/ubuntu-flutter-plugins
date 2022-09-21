import 'ubuntu_localizations.dart';

/// The translations for Spanish Castilian (`es`).
class UbuntuLocalizationsEs extends UbuntuLocalizations {
  UbuntuLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get countryCode => 'ES';

  @override
  String get languageName => 'Español';

  @override
  String get backAction => 'Volver';

  @override
  String get continueAction => 'Continuar';

  @override
  String get strongPassword => 'Contraseña fuerte';

  @override
  String get fairPassword => 'Contraseña aceptable';

  @override
  String get goodPassword => 'Contraseña buena';

  @override
  String get weakPassword => 'Contraseña débil';
}
