import 'ubuntu_localizations.dart';

/// The translations for Czech (`cs`).
class UbuntuLocalizationsCs extends UbuntuLocalizations {
  UbuntuLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get countryCode => 'CZ';

  @override
  String get languageName => 'Čeština';

  @override
  String get backAction => 'Jít zpět';

  @override
  String get continueAction => 'Pokračovat';

  @override
  String get strongPassword => 'Prolomení odolné heslo';

  @override
  String get fairPassword => 'Přijatelné heslo';

  @override
  String get goodPassword => 'Dobré heslo';

  @override
  String get weakPassword => 'Snadno prolomitelné heslo';

  @override
  String get altKey => 'Alt';

  @override
  String get controlKey => 'Control';

  @override
  String get metaKey => 'Meta';

  @override
  String get shiftKey => 'Shift';
}
