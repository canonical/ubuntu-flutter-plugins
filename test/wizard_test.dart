import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:flutter_wizard_example/wizard.dart';

abstract class Routes {
  Routes._();
  static const first = '/first';
  static const second = '/second';
  static const third = '/third';

  static Future<String> nextRoute(
    BuildContext context, {
    required String route,
  }) async {
    switch (route) {
      case Routes.first:
        return Routes.second;
      case Routes.second:
        return Routes.third;
      default:
        throw UnimplementedError(route);
    }
  }
}

void main() {
  Future<void> pumpWizardApp(
    WidgetTester tester, {
    required String initialRoute,
    WizardNextRoute nextRoute = Routes.nextRoute,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Wizard(
          initialRoute: initialRoute,
          nextRoute: nextRoute,
          routes: {
            Routes.first: (_) => const Text(Routes.first),
            Routes.second: (_) => const Text(Routes.second),
            Routes.third: (_) => const Text(Routes.third),
          },
        ),
      ),
    );
  }

  testWidgets('initial route set to first page', (tester) async {
    await pumpWizardApp(tester, initialRoute: Routes.first);

    expect(find.text(Routes.first), findsOneWidget);
    expect(find.text(Routes.second), findsNothing);
    expect(find.text(Routes.third), findsNothing);
  });

  testWidgets('initial route set to second page', (tester) async {
    await pumpWizardApp(tester, initialRoute: Routes.second);

    expect(find.text(Routes.first), findsNothing);
    expect(find.text(Routes.second), findsOneWidget);
    expect(find.text(Routes.third), findsNothing);
  });

  testWidgets('navigate back and forth', (tester) async {
    await pumpWizardApp(tester, initialRoute: Routes.first);

    final firstPage = find.text(Routes.first);
    final secondPage = find.text(Routes.second);
    final thirdPage = find.text(Routes.third);

    expect(firstPage, findsOneWidget);
    expect(secondPage, findsNothing);
    expect(thirdPage, findsNothing);

    // 1st -> 2nd
    final firstWizardScope = Wizard.of(tester.element(firstPage));
    expect(firstWizardScope, isNotNull);

    await firstWizardScope.next();
    await tester.pumpAndSettle();

    expect(firstPage, findsNothing);
    expect(secondPage, findsOneWidget);
    expect(thirdPage, findsNothing);

    // 2nd -> 3rd
    final secondWizardScope = Wizard.of(tester.element(secondPage));
    expect(secondWizardScope, isNotNull);

    await secondWizardScope.next();
    await tester.pumpAndSettle();

    expect(firstPage, findsNothing);
    expect(secondPage, findsNothing);
    expect(thirdPage, findsOneWidget);

    // 3rd -> 2nd
    final thirdWizardScope = Wizard.of(tester.element(thirdPage));
    expect(thirdWizardScope, isNotNull);

    await thirdWizardScope.back();
    await tester.pumpAndSettle();

    expect(firstPage, findsNothing);
    expect(secondPage, findsOneWidget);
    expect(thirdPage, findsNothing);

    // 2nd -> 1st
    await secondWizardScope.back();
    await tester.pumpAndSettle();

    expect(firstPage, findsOneWidget);
    expect(secondPage, findsNothing);
    expect(thirdPage, findsNothing);
  });

  testWidgets('navigate past first and last pages', (tester) async {
    await pumpWizardApp(tester, initialRoute: Routes.first);

    final page = find.text(Routes.first);
    expect(page, findsOneWidget);

    final wizard = Wizard.of(tester.element(page));
    expect(wizard, isNotNull);

    await wizard.next();
    await wizard.next();
    await expectLater(() => wizard.next(), throwsA(isUnimplementedError));

    await wizard.back();
    await wizard.back();
    await expectLater(() => wizard.back(), throwsA(isAssertionError));
  });
}
