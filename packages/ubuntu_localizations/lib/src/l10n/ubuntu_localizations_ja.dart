import 'ubuntu_localizations.dart';

/// The translations for Japanese (`ja`).
class UbuntuLocalizationsJa extends UbuntuLocalizations {
  UbuntuLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get countryCode => 'JP';

  @override
  String get languageName => '日本語';

  @override
  String get backAction => '戻る';

  @override
  String get continueAction => '次へ';

  @override
  String get strongPassword => '強力なパスワード';

  @override
  String get fairPassword => 'まあまあなパスワード';

  @override
  String get goodPassword => '良いパスワード';

  @override
  String get weakPassword => '弱いパスワード';

  @override
  String get altKey => 'Alt';

  @override
  String get controlKey => 'Control';

  @override
  String get metaKey => 'Meta';

  @override
  String get shiftKey => 'Shift';
}
