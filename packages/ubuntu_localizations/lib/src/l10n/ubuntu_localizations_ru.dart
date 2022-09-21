import 'ubuntu_localizations.dart';

/// The translations for Russian (`ru`).
class UbuntuLocalizationsRu extends UbuntuLocalizations {
  UbuntuLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get countryCode => 'RU';

  @override
  String get languageName => 'Русский';

  @override
  String get backAction => 'Назад';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get strongPassword => 'Надёжный пароль';

  @override
  String get fairPassword => 'Неплохой пароль';

  @override
  String get goodPassword => 'Хороший пароль';

  @override
  String get weakPassword => 'Слабый пароль';
}
