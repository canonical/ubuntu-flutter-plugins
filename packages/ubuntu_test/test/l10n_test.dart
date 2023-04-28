import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_localizations/ubuntu_localizations.dart';
import 'package:ubuntu_test/ubuntu_test.dart';

void main() async {
  testWidgets('ubuntu localizations', (tester) async {
    await expectLater(() => tester.ulang.okLabel, throwsStateError);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: UbuntuLocalizations.localizationsDelegates,
        builder: (context, child) =>
            Text(UbuntuLocalizations.of(context).okLabel),
      ),
    );

    expect(tester.ulang.okLabel, 'OK');
    expect(find.text(tester.ulang.okLabel), findsOneWidget);
  });

  testWidgets('app localizations', (tester) async {
    await expectLater(() => tester.al10n.testLabel, throwsStateError);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) =>
            Text(AppLocalizations.of(context).testLabel),
      ),
    );

    expect(tester.al10n.testLabel, 'test');
    expect(find.text(tester.al10n.testLabel), findsOneWidget);
  });

  testWidgets('tap buttons', (tester) async {
    const labels = [
      'Back',
      'Cancel',
      'Close',
      'Continue',
      'Next',
      'OK',
      'Previous',
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
    ));

    await tester.tapBack();
    expect(actual, expected..add(tester.ulang.backLabel));

    await tester.tapCancel();
    expect(actual, expected..add(tester.ulang.cancelLabel));

    await tester.tapClose();
    expect(actual, expected..add(tester.ulang.closeLabel));

    await tester.tapContinue();
    expect(actual, expected..add(tester.ulang.continueLabel));

    await tester.tapNext();
    expect(actual, expected..add(tester.ulang.nextLabel));

    await tester.tapOk();
    expect(actual, expected..add(tester.ulang.okLabel));

    await tester.tapPrevious();
    expect(actual, expected..add(tester.ulang.previousLabel));
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

extension AppLocalizationsTester on WidgetTester {
  AppLocalizations get al10n =>
      localizations<AppLocalizations>(AppLocalizations);
}
