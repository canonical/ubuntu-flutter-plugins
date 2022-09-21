import 'ubuntu_localizations.dart';

/// The translations for Chinese (`zh`).
class UbuntuLocalizationsZh extends UbuntuLocalizations {
  UbuntuLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get countryCode => 'CN';

  @override
  String get languageName => '中文（简体）';

  @override
  String get backAction => '返回';

  @override
  String get continueAction => '继续';

  @override
  String get strongPassword => '强密码';

  @override
  String get fairPassword => '公平密码';

  @override
  String get goodPassword => '好的密码';

  @override
  String get weakPassword => '弱密码';
}
