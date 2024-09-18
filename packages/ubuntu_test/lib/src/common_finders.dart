import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          (find.text(
            tr(l10n),
            findRichText: findRichText,
            skipOffstage: skipOffstage,
          ) as MatchFinder)
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

  /// Finds a _Done_ label.
  Finder get doneLabel => ul10n((l10n) => l10n.doneLabel);

  /// Finds a _Next_ label.
  Finder get nextLabel => ul10n((l10n) => l10n.nextLabel);

  /// Finds a _No_ label.
  Finder get noLabel => ul10n((l10n) => l10n.noLabel);

  /// Finds an _Ok_ label.
  Finder get okLabel => ul10n((l10n) => l10n.okLabel);

  /// Finds a _Previous_ label.
  Finder get previousLabel => ul10n((l10n) => l10n.previousLabel);

  /// Finds a _Yes_ label.
  Finder get yesLabel => ul10n((l10n) => l10n.yesLabel);

  /// Finds [Image] by [assetName].
  Finder asset(String assetName, {bool skipOffstage = true}) {
    return byWidgetPredicate(
      (w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName.endsWith(assetName),
      skipOffstage: skipOffstage,
    );
  }

  /// Finds [Html] by [data].
  Finder html(String data, {bool skipOffstage = true}) {
    return byWidgetPredicate(
      (w) => w is Html && w.data == data,
      skipOffstage: skipOffstage,
    );
  }

  /// Finds [MarkdownBody] by [data].
  Finder markdownBody(String data, {bool skipOffstage = true}) {
    return byWidgetPredicate(
      (w) => w is MarkdownBody && w.data == data,
      skipOffstage: skipOffstage,
    );
  }

  /// Finds [SvgPicture] by [assetName].
  Finder svg(String assetName, {bool skipOffstage = true}) {
    return byWidgetPredicate(
      (w) =>
          w is SvgPicture &&
          w.bytesLoader is SvgAssetLoader &&
          (w.bytesLoader as SvgAssetLoader).assetName.endsWith(assetName),
      skipOffstage: skipOffstage,
    );
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

    return ((scope as dynamic)?.typeToResources as Map?)?[T] as T?;
  }
}
