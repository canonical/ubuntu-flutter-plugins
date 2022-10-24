# Ubuntu localizations for Flutter

Provides extra localizations for Flutter-based Ubuntu applications.

The `GlobalUbuntuLocalizations` class provides as list of localization delegates
for all languages supported by Ubuntu. Furthermore, it provides a few Material
localization delegates that are not provided by flutter_localizations.

## Usage

```dart
import 'package:ubuntu_localizations/ubuntu_localizations.dart';
import 'l10n/app_localizations.dart';
```

```dart
MaterialApp(
  localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
    ...AppLocalizations.localizationsDelegates,
    ...GlobalUbuntuLocalizations.delegates,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
)
```

```dart
Text(UbuntuLocalizations.of(context).languageName)
```

## Generate Material localizations

Download [CLDR](https://cldr.unicode.org/) and run:

```bash
dart run date_time_patterns.dart [/path/to/cldr/common/main/<locale>.xml]
dart run date_time_symbols.dart [/path/to/cldr/common/main/<locale>.xml]
```

This prints the date and time patterns and symbols specified in the CLDR file.
Copy one of the existing `lib/src/material/material_localizations_<locale>.dart`
files as a starting point, and paste the patterns and symbols into the file.
Finally, add the new delegate to `lib/src/material/material_localizations.dart`.
