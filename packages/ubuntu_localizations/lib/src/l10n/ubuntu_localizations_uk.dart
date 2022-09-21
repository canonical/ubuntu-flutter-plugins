import 'ubuntu_localizations.dart';

/// The translations for Ukrainian (`uk`).
class UbuntuLocalizationsUk extends UbuntuLocalizations {
  UbuntuLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get countryCode => 'UA';

  @override
  String get languageName => 'Українська';

  @override
  String get backAction => 'Назад';

  @override
  String get continueAction => 'Продовжити';

  @override
  String get strongPassword => 'Міцний пароль';

  @override
  String get fairPassword => 'Задовільний пароль';

  @override
  String get goodPassword => 'Гарний пароль';

  @override
  String get weakPassword => 'Слабкий пароль';
}
