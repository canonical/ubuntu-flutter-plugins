import 'ubuntu_localizations.dart';

/// The translations for Korean (`ko`).
class UbuntuLocalizationsKo extends UbuntuLocalizations {
  UbuntuLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get countryCode => 'KR';

  @override
  String get languageName => '한국어';

  @override
  String get backAction => '뒤로 가기';

  @override
  String get continueAction => '계속하기';

  @override
  String get strongPassword => '강한 암호';

  @override
  String get fairPassword => '양호한 암호';

  @override
  String get goodPassword => '좋은 암호';

  @override
  String get weakPassword => '약한 암호';
}
