import 'ubuntu_localizations.dart';

/// The translations for Arabic (`ar`).
class UbuntuLocalizationsAr extends UbuntuLocalizations {
  UbuntuLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get countryCode => 'EG';

  @override
  String get languageName => 'عربي';

  @override
  String get backAction => 'العودة';

  @override
  String get continueAction => 'المواصلة';

  @override
  String get strongPassword => 'كلمة مرور قوية';

  @override
  String get fairPassword => 'كلمة مرور مقبولة';

  @override
  String get goodPassword => 'كلمة مرور جيدة';

  @override
  String get weakPassword => 'كلمة مرور ضعيفة';
}
