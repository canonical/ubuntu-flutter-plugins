import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'ubuntu_localizations_am.dart';
import 'ubuntu_localizations_ar.dart';
import 'ubuntu_localizations_be.dart';
import 'ubuntu_localizations_bg.dart';
import 'ubuntu_localizations_bn.dart';
import 'ubuntu_localizations_bo.dart';
import 'ubuntu_localizations_bs.dart';
import 'ubuntu_localizations_ca.dart';
import 'ubuntu_localizations_cs.dart';
import 'ubuntu_localizations_cy.dart';
import 'ubuntu_localizations_da.dart';
import 'ubuntu_localizations_de.dart';
import 'ubuntu_localizations_dz.dart';
import 'ubuntu_localizations_el.dart';
import 'ubuntu_localizations_en.dart';
import 'ubuntu_localizations_eo.dart';
import 'ubuntu_localizations_es.dart';
import 'ubuntu_localizations_et.dart';
import 'ubuntu_localizations_eu.dart';
import 'ubuntu_localizations_fa.dart';
import 'ubuntu_localizations_fi.dart';
import 'ubuntu_localizations_fr.dart';
import 'ubuntu_localizations_ga.dart';
import 'ubuntu_localizations_gl.dart';
import 'ubuntu_localizations_gu.dart';
import 'ubuntu_localizations_he.dart';
import 'ubuntu_localizations_hi.dart';
import 'ubuntu_localizations_hr.dart';
import 'ubuntu_localizations_hu.dart';
import 'ubuntu_localizations_id.dart';
import 'ubuntu_localizations_is.dart';
import 'ubuntu_localizations_it.dart';
import 'ubuntu_localizations_ja.dart';
import 'ubuntu_localizations_ka.dart';
import 'ubuntu_localizations_kk.dart';
import 'ubuntu_localizations_km.dart';
import 'ubuntu_localizations_kn.dart';
import 'ubuntu_localizations_ko.dart';
import 'ubuntu_localizations_ku.dart';
import 'ubuntu_localizations_lo.dart';
import 'ubuntu_localizations_lt.dart';
import 'ubuntu_localizations_lv.dart';
import 'ubuntu_localizations_mk.dart';
import 'ubuntu_localizations_ml.dart';
import 'ubuntu_localizations_mr.dart';
import 'ubuntu_localizations_my.dart';
import 'ubuntu_localizations_nb.dart';
import 'ubuntu_localizations_ne.dart';
import 'ubuntu_localizations_nl.dart';
import 'ubuntu_localizations_nn.dart';
import 'ubuntu_localizations_oc.dart';
import 'ubuntu_localizations_pa.dart';
import 'ubuntu_localizations_pl.dart';
import 'ubuntu_localizations_pt.dart';
import 'ubuntu_localizations_ro.dart';
import 'ubuntu_localizations_ru.dart';
import 'ubuntu_localizations_se.dart';
import 'ubuntu_localizations_si.dart';
import 'ubuntu_localizations_sk.dart';
import 'ubuntu_localizations_sl.dart';
import 'ubuntu_localizations_sq.dart';
import 'ubuntu_localizations_sr.dart';
import 'ubuntu_localizations_sv.dart';
import 'ubuntu_localizations_ta.dart';
import 'ubuntu_localizations_te.dart';
import 'ubuntu_localizations_tg.dart';
import 'ubuntu_localizations_th.dart';
import 'ubuntu_localizations_tl.dart';
import 'ubuntu_localizations_tr.dart';
import 'ubuntu_localizations_ug.dart';
import 'ubuntu_localizations_uk.dart';
import 'ubuntu_localizations_vi.dart';
import 'ubuntu_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of UbuntuLocalizations
/// returned by `UbuntuLocalizations.of(context)`.
///
/// Applications need to include `UbuntuLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/ubuntu_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: UbuntuLocalizations.localizationsDelegates,
///   supportedLocales: UbuntuLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the UbuntuLocalizations.supportedLocales
/// property.
abstract class UbuntuLocalizations {
  UbuntuLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static UbuntuLocalizations of(BuildContext context) {
    return Localizations.of<UbuntuLocalizations>(context, UbuntuLocalizations)!;
  }

  static const LocalizationsDelegate<UbuntuLocalizations> delegate =
      _UbuntuLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('ar'),
    Locale('be'),
    Locale('bg'),
    Locale('bn'),
    Locale('bo'),
    Locale('bs'),
    Locale('ca'),
    Locale('cs'),
    Locale('cy'),
    Locale('da'),
    Locale('de'),
    Locale('dz'),
    Locale('el'),
    Locale('en'),
    Locale('eo'),
    Locale('es'),
    Locale('et'),
    Locale('eu'),
    Locale('fa'),
    Locale('fi'),
    Locale('fr'),
    Locale('ga'),
    Locale('gl'),
    Locale('gu'),
    Locale('he'),
    Locale('hi'),
    Locale('hr'),
    Locale('hu'),
    Locale('id'),
    Locale('is'),
    Locale('it'),
    Locale('ja'),
    Locale('ka'),
    Locale('kk'),
    Locale('km'),
    Locale('kn'),
    Locale('ko'),
    Locale('ku'),
    Locale('lo'),
    Locale('lt'),
    Locale('lv'),
    Locale('mk'),
    Locale('ml'),
    Locale('mr'),
    Locale('my'),
    Locale('nb'),
    Locale('ne'),
    Locale('nl'),
    Locale('nn'),
    Locale('oc'),
    Locale('pa'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ro'),
    Locale('ru'),
    Locale('se'),
    Locale('si'),
    Locale('sk'),
    Locale('sl'),
    Locale('sq'),
    Locale('sr'),
    Locale('sv'),
    Locale('ta'),
    Locale('te'),
    Locale('tg'),
    Locale('th'),
    Locale('tl'),
    Locale('tr'),
    Locale('ug'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
    Locale('zh', 'TW')
  ];

  /// No description provided for @countryCode.
  ///
  /// In en, this message translates to:
  /// **'US'**
  String get countryCode;

  /// The display name for the language. Leave empty to exclude the language from the list of languages on the welcome screen.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageName;

  /// No description provided for @backAction.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get backAction;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @strongPassword.
  ///
  /// In en, this message translates to:
  /// **'Strong password'**
  String get strongPassword;

  /// No description provided for @fairPassword.
  ///
  /// In en, this message translates to:
  /// **'Fair password'**
  String get fairPassword;

  /// No description provided for @goodPassword.
  ///
  /// In en, this message translates to:
  /// **'Good password'**
  String get goodPassword;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Weak password'**
  String get weakPassword;

  /// No description provided for @altKey.
  ///
  /// In en, this message translates to:
  /// **'Alt'**
  String get altKey;

  /// No description provided for @controlKey.
  ///
  /// In en, this message translates to:
  /// **'Control'**
  String get controlKey;

  /// No description provided for @metaKey.
  ///
  /// In en, this message translates to:
  /// **'Meta'**
  String get metaKey;

  /// No description provided for @shiftKey.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get shiftKey;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

  /// No description provided for @addLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addLabel;

  /// No description provided for @allLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLabel;

  /// No description provided for @applyLabel.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyLabel;

  /// No description provided for @ascendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascendingLabel;

  /// No description provided for @backLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backLabel;

  /// No description provided for @boldLabel.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get boldLabel;

  /// No description provided for @bottomLabel.
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get bottomLabel;

  /// No description provided for @cancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// No description provided for @centerLabel.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get centerLabel;

  /// No description provided for @clearLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearLabel;

  /// No description provided for @closeLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLabel;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @connectLabel.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectLabel;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @copyLabel.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyLabel;

  /// No description provided for @createLabel.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createLabel;

  /// No description provided for @cutLabel.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cutLabel;

  /// No description provided for @decreaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decreaseLabel;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @descendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descendingLabel;

  /// No description provided for @discardLabel.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardLabel;

  /// No description provided for @disconnectLabel.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnectLabel;

  /// No description provided for @doneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneLabel;

  /// No description provided for @downloadLabel.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadLabel;

  /// No description provided for @editLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editLabel;

  /// No description provided for @enterLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enterLabel;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @executeLabel.
  ///
  /// In en, this message translates to:
  /// **'Execute'**
  String get executeLabel;

  /// No description provided for @exitLabel.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitLabel;

  /// No description provided for @fileLabel.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get fileLabel;

  /// No description provided for @fillLabel.
  ///
  /// In en, this message translates to:
  /// **'Fill'**
  String get fillLabel;

  /// No description provided for @findLabel.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get findLabel;

  /// No description provided for @firstLabel.
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get firstLabel;

  /// No description provided for @fontLabel.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get fontLabel;

  /// No description provided for @forwardLabel.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get forwardLabel;

  /// No description provided for @fullscreenLabel.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get fullscreenLabel;

  /// No description provided for @goBackLabel.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBackLabel;

  /// No description provided for @helpLabel.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpLabel;

  /// No description provided for @homeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

  /// No description provided for @importLabel.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importLabel;

  /// No description provided for @increaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increaseLabel;

  /// No description provided for @indexLabel.
  ///
  /// In en, this message translates to:
  /// **'Index'**
  String get indexLabel;

  /// No description provided for @informationLabel.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get informationLabel;

  /// No description provided for @insertLabel.
  ///
  /// In en, this message translates to:
  /// **'Insert'**
  String get insertLabel;

  /// No description provided for @italicLabel.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italicLabel;

  /// No description provided for @landscapeLabel.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get landscapeLabel;

  /// No description provided for @lastLabel.
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get lastLabel;

  /// No description provided for @leaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveLabel;

  /// No description provided for @leftLabel.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get leftLabel;

  /// No description provided for @mediaLabel.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get mediaLabel;

  /// No description provided for @networkLabel.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkLabel;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @nextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextLabel;

  /// No description provided for @noLabel.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noLabel;

  /// No description provided for @noneLabel.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneLabel;

  /// No description provided for @normalLabel.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normalLabel;

  /// No description provided for @okLabel.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okLabel;

  /// No description provided for @openLabel.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openLabel;

  /// No description provided for @pasteLabel.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get pasteLabel;

  /// No description provided for @pauseLabel.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseLabel;

  /// No description provided for @playLabel.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playLabel;

  /// No description provided for @portraitLabel.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get portraitLabel;

  /// No description provided for @preferencesLabel.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesLabel;

  /// No description provided for @previousLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousLabel;

  /// No description provided for @printLabel.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get printLabel;

  /// No description provided for @printPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Print Preview'**
  String get printPreviewLabel;

  /// No description provided for @propertiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get propertiesLabel;

  /// No description provided for @questionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get questionLabel;

  /// No description provided for @quitLabel.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quitLabel;

  /// No description provided for @recordLabel.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recordLabel;

  /// No description provided for @redoLabel.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redoLabel;

  /// No description provided for @refreshLabel.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshLabel;

  /// No description provided for @removeLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeLabel;

  /// No description provided for @renameLabel.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameLabel;

  /// No description provided for @resetLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetLabel;

  /// No description provided for @restartLabel.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restartLabel;

  /// No description provided for @restoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreLabel;

  /// No description provided for @retryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLabel;

  /// No description provided for @revertLabel.
  ///
  /// In en, this message translates to:
  /// **'Revert'**
  String get revertLabel;

  /// No description provided for @rewindLabel.
  ///
  /// In en, this message translates to:
  /// **'Rewind'**
  String get rewindLabel;

  /// No description provided for @rightLabel.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get rightLabel;

  /// No description provided for @saveAsLabel.
  ///
  /// In en, this message translates to:
  /// **'Save As'**
  String get saveAsLabel;

  /// No description provided for @saveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLabel;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabel;

  /// No description provided for @selectAllLabel.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAllLabel;

  /// No description provided for @selectLabel.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectLabel;

  /// No description provided for @sendLabel.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendLabel;

  /// No description provided for @skipLabel.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipLabel;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortLabel;

  /// No description provided for @stopLabel.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopLabel;

  /// No description provided for @strikeThroughLabel.
  ///
  /// In en, this message translates to:
  /// **'Strike Through'**
  String get strikeThroughLabel;

  /// No description provided for @submitLabel.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitLabel;

  /// No description provided for @topLabel.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get topLabel;

  /// No description provided for @undoLabel.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoLabel;

  /// No description provided for @updateLabel.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateLabel;

  /// No description provided for @upLabel.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get upLabel;

  /// No description provided for @viewLabel.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewLabel;

  /// No description provided for @warningLabel.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warningLabel;

  /// No description provided for @windowLabel.
  ///
  /// In en, this message translates to:
  /// **'Window'**
  String get windowLabel;

  /// No description provided for @yesLabel.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesLabel;

  /// No description provided for @zoomInLabel.
  ///
  /// In en, this message translates to:
  /// **'Zoom In'**
  String get zoomInLabel;

  /// No description provided for @zoomOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Zoom Out'**
  String get zoomOutLabel;

  /// No description provided for @byte.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get byte;

  /// No description provided for @kilobyte.
  ///
  /// In en, this message translates to:
  /// **'kB'**
  String get kilobyte;

  /// No description provided for @megabyte.
  ///
  /// In en, this message translates to:
  /// **'MB'**
  String get megabyte;

  /// No description provided for @gigabyte.
  ///
  /// In en, this message translates to:
  /// **'GB'**
  String get gigabyte;

  /// No description provided for @terabyte.
  ///
  /// In en, this message translates to:
  /// **'TB'**
  String get terabyte;

  /// No description provided for @petabyte.
  ///
  /// In en, this message translates to:
  /// **'PB'**
  String get petabyte;
}

class _UbuntuLocalizationsDelegate
    extends LocalizationsDelegate<UbuntuLocalizations> {
  const _UbuntuLocalizationsDelegate();

  @override
  Future<UbuntuLocalizations> load(Locale locale) {
    return SynchronousFuture<UbuntuLocalizations>(
        lookupUbuntuLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'am',
        'ar',
        'be',
        'bg',
        'bn',
        'bo',
        'bs',
        'ca',
        'cs',
        'cy',
        'da',
        'de',
        'dz',
        'el',
        'en',
        'eo',
        'es',
        'et',
        'eu',
        'fa',
        'fi',
        'fr',
        'ga',
        'gl',
        'gu',
        'he',
        'hi',
        'hr',
        'hu',
        'id',
        'is',
        'it',
        'ja',
        'ka',
        'kk',
        'km',
        'kn',
        'ko',
        'ku',
        'lo',
        'lt',
        'lv',
        'mk',
        'ml',
        'mr',
        'my',
        'nb',
        'ne',
        'nl',
        'nn',
        'oc',
        'pa',
        'pl',
        'pt',
        'ro',
        'ru',
        'se',
        'si',
        'sk',
        'sl',
        'sq',
        'sr',
        'sv',
        'ta',
        'te',
        'tg',
        'th',
        'tl',
        'tr',
        'ug',
        'uk',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_UbuntuLocalizationsDelegate old) => false;
}

UbuntuLocalizations lookupUbuntuLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return UbuntuLocalizationsPtBr();
        }
        break;
      }
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return UbuntuLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return UbuntuLocalizationsAm();
    case 'ar':
      return UbuntuLocalizationsAr();
    case 'be':
      return UbuntuLocalizationsBe();
    case 'bg':
      return UbuntuLocalizationsBg();
    case 'bn':
      return UbuntuLocalizationsBn();
    case 'bo':
      return UbuntuLocalizationsBo();
    case 'bs':
      return UbuntuLocalizationsBs();
    case 'ca':
      return UbuntuLocalizationsCa();
    case 'cs':
      return UbuntuLocalizationsCs();
    case 'cy':
      return UbuntuLocalizationsCy();
    case 'da':
      return UbuntuLocalizationsDa();
    case 'de':
      return UbuntuLocalizationsDe();
    case 'dz':
      return UbuntuLocalizationsDz();
    case 'el':
      return UbuntuLocalizationsEl();
    case 'en':
      return UbuntuLocalizationsEn();
    case 'eo':
      return UbuntuLocalizationsEo();
    case 'es':
      return UbuntuLocalizationsEs();
    case 'et':
      return UbuntuLocalizationsEt();
    case 'eu':
      return UbuntuLocalizationsEu();
    case 'fa':
      return UbuntuLocalizationsFa();
    case 'fi':
      return UbuntuLocalizationsFi();
    case 'fr':
      return UbuntuLocalizationsFr();
    case 'ga':
      return UbuntuLocalizationsGa();
    case 'gl':
      return UbuntuLocalizationsGl();
    case 'gu':
      return UbuntuLocalizationsGu();
    case 'he':
      return UbuntuLocalizationsHe();
    case 'hi':
      return UbuntuLocalizationsHi();
    case 'hr':
      return UbuntuLocalizationsHr();
    case 'hu':
      return UbuntuLocalizationsHu();
    case 'id':
      return UbuntuLocalizationsId();
    case 'is':
      return UbuntuLocalizationsIs();
    case 'it':
      return UbuntuLocalizationsIt();
    case 'ja':
      return UbuntuLocalizationsJa();
    case 'ka':
      return UbuntuLocalizationsKa();
    case 'kk':
      return UbuntuLocalizationsKk();
    case 'km':
      return UbuntuLocalizationsKm();
    case 'kn':
      return UbuntuLocalizationsKn();
    case 'ko':
      return UbuntuLocalizationsKo();
    case 'ku':
      return UbuntuLocalizationsKu();
    case 'lo':
      return UbuntuLocalizationsLo();
    case 'lt':
      return UbuntuLocalizationsLt();
    case 'lv':
      return UbuntuLocalizationsLv();
    case 'mk':
      return UbuntuLocalizationsMk();
    case 'ml':
      return UbuntuLocalizationsMl();
    case 'mr':
      return UbuntuLocalizationsMr();
    case 'my':
      return UbuntuLocalizationsMy();
    case 'nb':
      return UbuntuLocalizationsNb();
    case 'ne':
      return UbuntuLocalizationsNe();
    case 'nl':
      return UbuntuLocalizationsNl();
    case 'nn':
      return UbuntuLocalizationsNn();
    case 'oc':
      return UbuntuLocalizationsOc();
    case 'pa':
      return UbuntuLocalizationsPa();
    case 'pl':
      return UbuntuLocalizationsPl();
    case 'pt':
      return UbuntuLocalizationsPt();
    case 'ro':
      return UbuntuLocalizationsRo();
    case 'ru':
      return UbuntuLocalizationsRu();
    case 'se':
      return UbuntuLocalizationsSe();
    case 'si':
      return UbuntuLocalizationsSi();
    case 'sk':
      return UbuntuLocalizationsSk();
    case 'sl':
      return UbuntuLocalizationsSl();
    case 'sq':
      return UbuntuLocalizationsSq();
    case 'sr':
      return UbuntuLocalizationsSr();
    case 'sv':
      return UbuntuLocalizationsSv();
    case 'ta':
      return UbuntuLocalizationsTa();
    case 'te':
      return UbuntuLocalizationsTe();
    case 'tg':
      return UbuntuLocalizationsTg();
    case 'th':
      return UbuntuLocalizationsTh();
    case 'tl':
      return UbuntuLocalizationsTl();
    case 'tr':
      return UbuntuLocalizationsTr();
    case 'ug':
      return UbuntuLocalizationsUg();
    case 'uk':
      return UbuntuLocalizationsUk();
    case 'vi':
      return UbuntuLocalizationsVi();
    case 'zh':
      return UbuntuLocalizationsZh();
  }

  throw FlutterError(
      'UbuntuLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
