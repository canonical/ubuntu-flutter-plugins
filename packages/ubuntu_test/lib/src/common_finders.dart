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

  /// Finds a _Back_ label.
  Finder get backLabel => ul10n((l10n) => l10n.backLabel);

  /// Finds a _Cancel_ label.
  Finder get cancelLabel => ul10n((l10n) => l10n.cancelLabel);

  /// Finds a _Close_ label.
  Finder get closeLabel => ul10n((l10n) => l10n.closeLabel);

  /// Finds a _Continue_ label.
  Finder get continueLabel => ul10n((l10n) => l10n.continueLabel);

  /// Finds a _Next_ label.
  Finder get nextLabel => ul10n((l10n) => l10n.nextLabel);

  /// Finds an _Ok_ label.
  Finder get okLabel => ul10n((l10n) => l10n.okLabel);

  /// Finds a _Previous_ label.
  Finder get previousLabel => ul10n((l10n) => l10n.previousLabel);
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
