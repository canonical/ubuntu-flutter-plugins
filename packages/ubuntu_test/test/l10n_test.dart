import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_localizations/ubuntu_localizations.dart';
import 'package:ubuntu_test/ubuntu_test.dart';

void main() async {
  testWidgets('ubuntu localizations', (tester) async {
    expect(find.ul10n((l10n) => l10n.okLabel), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: UbuntuLocalizations.localizationsDelegates,
        builder: (context, child) => Column(
          children: [
            Text(UbuntuLocalizations.of(context).languageName),
            Localizations.override(
              context: context,
              locale: const Locale('fr'),
              child: Builder(
                builder: (context) =>
                    Text(UbuntuLocalizations.of(context).languageName),
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.text('English'), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);
    expect(find.ul10n((l10n) => l10n.languageName), findsNWidgets(2));
  });

  testWidgets('app localizations', (tester) async {
    expect(find.l10n<AppLocalizations>((l10n) => l10n.testLabel), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) =>
            Text(AppLocalizations.of(context).testLabel),
      ),
    );

    expect(
        find.l10n<AppLocalizations>((l10n) => l10n.testLabel), findsOneWidget,);
  });

  testWidgets('tap buttons', (tester) async {
    final ul10n = await UbuntuLocalizations.delegate.load(const Locale('en'));

    final labels = [
      ul10n.backLabel,
      ul10n.cancelLabel,
      ul10n.closeLabel,
      ul10n.continueLabel,
      ul10n.doneLabel,
      ul10n.nextLabel,
      ul10n.noLabel,
      ul10n.okLabel,
      ul10n.previousLabel,
      ul10n.yesLabel,
    ];

    final actual = <String>[];
    final expected = <String>[];

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: UbuntuLocalizations.localizationsDelegates,
      home: Column(
        children: [
          for (final label in labels)
            ElevatedButton(
              child: Text(label),
              onPressed: () => actual.add(label),
            ),
        ],
      ),
    ),);

    await tester.tapBack();
    expect(actual, expected..add(ul10n.backLabel));

    await tester.tapCancel();
    expect(actual, expected..add(ul10n.cancelLabel));

    await tester.tapClose();
    expect(actual, expected..add(ul10n.closeLabel));

    await tester.tapContinue();
    expect(actual, expected..add(ul10n.continueLabel));

    await tester.tapDone();
    expect(actual, expected..add(ul10n.doneLabel));

    await tester.tapNext();
    expect(actual, expected..add(ul10n.nextLabel));

    await tester.tapNo();
    expect(actual, expected..add(ul10n.noLabel));

    await tester.tapOk();
    expect(actual, expected..add(ul10n.okLabel));

    await tester.tapPrevious();
    expect(actual, expected..add(ul10n.previousLabel));

    await tester.tapYes();
    expect(actual, expected..add(ul10n.yesLabel));
  });
}

class AppLocalizations {
  const AppLocalizations();

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
  ];

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  String get testLabel => 'test';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture(const AppLocalizations());
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
