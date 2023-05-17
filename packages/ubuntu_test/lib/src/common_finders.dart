import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_localizations/ubuntu_localizations.dart';

/// Localization function.
typedef LocalizationFunction<T> = String Function(T);

/// Ubuntu localization function.
typedef UbuntuLocalizationFunction = String Function(UbuntuLocalizations);

/// Common finder extensions.
extension UbuntuCommonFinders on CommonFinders {
  /// Finds a widget with text translated in [UbuntuLocalizations].
  Finder ul10n(UbuntuLocalizationFunction tr) => l10n<UbuntuLocalizations>(tr);

  /// Finds a widget with translated text.
  Finder l10n<T>(
    LocalizationFunction<T> tr, {
    bool findRichText = false,
    bool skipOffstage = true,
  }) {
    return byElementPredicate((element) {
      final l10n = element.lookupLocalizations<T>();
      return l10n != null &&
          (find.text(tr(l10n),
                  findRichText: findRichText,
                  skipOffstage: skipOffstage) as MatchFinder)
              .matches(element);
    });
  }
}

extension on Element {
  T? lookupLocalizations<T>() {
    Widget? scope;
    visitAncestorElements((element) {
      if (element.widget.runtimeType.toString() == '_LocalizationsScope') {
        scope = element.widget;
      }
      return scope == null;
    });
    return ((scope as dynamic)?.typeToResources as Map?)?[T];
  }
}
