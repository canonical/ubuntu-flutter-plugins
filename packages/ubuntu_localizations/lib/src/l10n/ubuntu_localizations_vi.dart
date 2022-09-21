import 'ubuntu_localizations.dart';

/// The translations for Vietnamese (`vi`).
class UbuntuLocalizationsVi extends UbuntuLocalizations {
  UbuntuLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get countryCode => 'VN';

  @override
  String get languageName => 'Tiếng Việt';

  @override
  String get backAction => 'Quay trở lại';

  @override
  String get continueAction => 'tiếp tục';

  @override
  String get strongPassword => 'mật khẩu mạnh';

  @override
  String get fairPassword => 'Mật khẩu hợp lý';

  @override
  String get goodPassword => '';

  @override
  String get weakPassword => 'Mật khẩu yếu';
}
