import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizard_router/wizard_router.dart';

abstract class Routes {
  Routes._();
  static const first = '/first';
  static const second = '/second';
  static const third = '/third';
  static const fourth = '/fourth';
}

void main() {
  Future<void> pumpWizardApp(
    WidgetTester tester, {
    String? initialRoute,
    required Map<String, WizardRoute> routes,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Wizard(
          initialRoute: initialRoute,
          routes: routes,
        ),
      ),
    );
  }

  testWidgets('no initial route set', (tester) async {
    await pumpWizardApp(
      tester,
      routes: {
        Routes.first: WizardRoute(builder: (_) => const Text(Routes.first)),
        Routes.second: WizardRoute(builder: (_) => const Text(Routes.second)),
        Routes.third: WizardRoute(builder: (_) => const Text(Routes.third)),
      },
    );

    expect(find.text(Routes.first), findsOneWidget);
    expect(find.text(Routes.second), findsNothing);
    expect(find.text(Routes.third), findsNothing);
  });

  testWidgets('initial route set to first', (tester) async {
    await pumpWizardApp(
      tester,
      initialRoute: Routes.first,
      routes: {
        Routes.first: WizardRoute(builder: (_) => const Text(Routes.first)),
        Routes.second: WizardRoute(builder: (_) => const Text(Routes.second)),
        Routes.third: WizardRoute(builder: (_) => const Text(Routes.third)),
      },
    );

    expect(find.text(Routes.first), findsOneWidget);
    expect(find.text(Routes.second), findsNothing);
    expect(find.text(Routes.third), findsNothing);
  });

  testWidgets('initial route set to second', (tester) async {
    await pumpWizardApp(
      tester,
      initialRoute: Routes.second,
      routes: {
        Routes.first: WizardRoute(builder: (_) => const Text(Routes.first)),
        Routes.second: WizardRoute(builder: (_) => const Text(Routes.second)),
        Routes.third: WizardRoute(builder: (_) => const Text(Routes.third)),
      },
    );

    expect(find.text(Routes.first), findsNothing);
    expect(find.text(Routes.second), findsOneWidget);
    expect(find.text(Routes.third), findsNothing);
  });

  testWidgets('navigate back and forth', (tester) async {
    await pumpWizardApp(
      tester,
      routes: {
        Routes.first: WizardRoute(builder: (_) => const Text(Routes.first)),
        Routes.second: WizardRoute(builder: (_) => const Text(Routes.second)),
        Routes.third: WizardRoute(builder: (_) => const Text(Routes.third)),
      },
    );

    final firstPage = find.text(Routes.first);
    final secondPage = find.text(Routes.second);
    final thirdPage = find.text(Routes.third);

    expect(firstPage, findsOneWidget);
    expect(secondPage, findsNothing);
    expect(thirdPage, findsNothing);

    // 1st -> 2nd
    final firstWizardScope = Wizard.of(tester.element(firstPage));
    expect(firstWizardScope, isNotNull);

    firstWizardScope.next();
    await tester.pumpAndSettle();

    expect(firstPage, findsNothing);
    expect(secondPage, findsOneWidget);
    expect(thirdPage, findsNothing);

    // 2nd -> 3rd
    final secondWizardScope = Wizard.of(tester.element(secondPage));
    expect(secondWizardScope, isNotNull);

    secondWizardScope.next();
    await tester.pumpAndSettle();

    expect(firstPage, findsNothing);
    expect(secondPage, findsNothing);
    expect(thirdPage, findsOneWidget);

    // 3rd -> 2nd
    final thirdWizardScope = Wizard.of(tester.element(thirdPage));
    expect(thirdWizardScope, isNotNull);

    thirdWizardScope.back();
    await tester.pumpAndSettle();

    expect(firstPage, findsNothing);
    expect(secondPage, findsOneWidget);
    expect(thirdPage, findsNothing);

    // 2nd -> 1st
    secondWizardScope.back();
    await tester.pumpAndSettle();

    expect(firstPage, findsOneWidget);
    expect(secondPage, findsNothing);
    expect(thirdPage, findsNothing);
  });

  testWidgets('navigate past first and last', (tester) async {
    await pumpWizardApp(
      tester,
      routes: {
        Routes.first: WizardRoute(builder: (_) => const Text(Routes.first)),
        Routes.second: WizardRoute(builder: (_) => const Text(Routes.second)),
        Routes.third: WizardRoute(builder: (_) => const Text(Routes.third)),
      },
    );

    final page = find.text(Routes.first);
    expect(page, findsOneWidget);

    final wizard = Wizard.of(tester.element(page));
    expect(wizard, isNotNull);

    wizard.next();
    wizard.next();
    await expectLater(() => wizard.next(), throwsAssertionError);

    wizard.back();
    wizard.back();
    await expectLater(() => wizard.back(), throwsAssertionError);
  });

  testWidgets('route conditions', (tester) async {
    var skipSecond = false;
    var skipThird = false;

    await pumpWizardApp(
      tester,
      routes: {
        Routes.first: WizardRoute(
          builder: (_) => const Text(Routes.first),
          onNext: (settings) {
            return !skipSecond
                ? Routes.second
                : !skipThird
                    ? Routes.third
                    : Routes.fourth;
          },
        ),
        Routes.second: WizardRoute(
          builder: (_) => const Text(Routes.second),
          onNext: (_) => skipThird ? Routes.fourth : Routes.second,
        ),
        Routes.third: WizardRoute(
          builder: (_) => const Text(Routes.third),
          onBack: (_) => skipSecond ? Routes.first : Routes.second,
        ),
        Routes.fourth: WizardRoute(
          builder: (_) => const Text(Routes.fourth),
          onBack: (_) => !skipThird
              ? Routes.third
              : !skipSecond
                  ? Routes.second
                  : Routes.first,
        ),
      },
    );

    final firstPage = find.text(Routes.first);
    final secondPage = find.text(Routes.second);
    final thirdPage = find.text(Routes.third);
    final fourthPage = find.text(Routes.fourth);

    expect(firstPage, findsOneWidget);
    expect(secondPage, findsNothing);
    expect(thirdPage, findsNothing);
    expect(fourthPage, findsNothing);

    // 1st -> 3rd
    final firstWizardScope = Wizard.of(tester.element(firstPage));
    expect(firstWizardScope, isNotNull);

    skipSecond = true;
    skipThird = false;
    firstWizardScope.next();
    await tester.pumpAndSettle();

    expect(firstPage, findsNothing);
    expect(secondPage, findsNothing);
    expect(thirdPage, findsOneWidget);
    expect(fourthPage, findsNothing);

    // 3rd -> 4th
    final thirdWizardScope = Wizard.of(tester.element(thirdPage));
    expect(thirdWizardScope, isNotNull);

    thirdWizardScope.next();
    await tester.pumpAndSettle();

    expect(firstPage, findsNothing);
    expect(secondPage, findsNothing);
    expect(thirdPage, findsNothing);
    expect(fourthPage, findsOneWidget);

    // 4th -> 1st
    final fourthWizardScope = Wizard.of(tester.element(fourthPage));
    expect(fourthWizardScope, isNotNull);

    skipSecond = true;
    skipThird = true;
    fourthWizardScope.back();
    await tester.pumpAndSettle();

    expect(firstPage, findsOneWidget);
    expect(secondPage, findsNothing);
    expect(thirdPage, findsNothing);
    expect(fourthPage, findsNothing);
  });

  testWidgets('invalid route conditions', (tester) async {
    String? nextRoute;
    String? backRoute;

    await pumpWizardApp(
      tester,
      routes: {
        Routes.first: WizardRoute(
          builder: (_) => const Text(Routes.first),
          onNext: (_) => nextRoute,
        ),
        Routes.second: WizardRoute(
          builder: (_) => const Text(Routes.second),
          onBack: (_) => backRoute,
        ),
      },
    );

    final firstPage = find.text(Routes.first);
    final secondPage = find.text(Routes.second);

    final firstWizardScope = Wizard.of(tester.element(firstPage));
    nextRoute = 'unknown';
    await expectLater(() => firstWizardScope.next(), throwsAssertionError);

    nextRoute = Routes.second;
    firstWizardScope.next();
    await tester.pumpAndSettle();

    final secondWizardScope = Wizard.of(tester.element(secondPage));
    backRoute = 'invalid';
    await expectLater(() => secondWizardScope.back(), throwsAssertionError);
  });

  testWidgets('pass arguments', (tester) async {
    await pumpWizardApp(
      tester,
      routes: {
        Routes.first: WizardRoute(builder: (_) => const Text(Routes.first)),
        Routes.second: WizardRoute(builder: (_) => const Text(Routes.second)),
      },
    );

    final firstPage = find.text(Routes.first);
    final firstWizardScope = Wizard.of(tester.element(firstPage));
    expect(firstWizardScope.arguments, isNull);

    firstWizardScope.next(arguments: 'something');
    await tester.pumpAndSettle();

    final secondPage = find.text(Routes.second);
    final secondWizardScope = Wizard.of(tester.element(secondPage));
    expect(secondWizardScope.arguments, equals('something'));
  });

  testWidgets('navigate home', (tester) async {
    await pumpWizardApp(
      tester,
      routes: {
        Routes.first: WizardRoute(builder: (_) => const Text(Routes.first)),
        Routes.second: WizardRoute(builder: (_) => const Text(Routes.second)),
        Routes.third: WizardRoute(builder: (_) => const Text(Routes.third)),
      },
    );

    final firstPage = find.text(Routes.first);
    final secondPage = find.text(Routes.second);
    final thirdPage = find.text(Routes.third);

    final wizard = Wizard.of(tester.element(firstPage));

    // 1st -> home
    await expectLater(() => wizard.home(), throwsAssertionError);

    // 2nd -> home
    wizard.next();
    await tester.pumpAndSettle();

    expect(firstPage, findsNothing);
    expect(secondPage, findsOneWidget);
    expect(thirdPage, findsNothing);

    wizard.home();
    await tester.pumpAndSettle();

    expect(firstPage, findsOneWidget);
    expect(secondPage, findsNothing);
    expect(thirdPage, findsNothing);

    // 3rd -> home
    wizard.next();
    await tester.pump();
    wizard.next();
    await tester.pumpAndSettle();

    expect(firstPage, findsNothing);
    expect(secondPage, findsNothing);
    expect(thirdPage, findsOneWidget);

    wizard.home();
    await tester.pumpAndSettle();

    expect(firstPage, findsOneWidget);
    expect(secondPage, findsNothing);
    expect(thirdPage, findsNothing);
  });

  testWidgets('has next or previous', (tester) async {
    await pumpWizardApp(
      tester,
      routes: {
        Routes.first: WizardRoute(builder: (_) => const Text(Routes.first)),
        Routes.second: WizardRoute(builder: (_) => const Text(Routes.second)),
        Routes.third: WizardRoute(builder: (_) => const Text(Routes.third)),
      },
    );

    final firstPage = find.text(Routes.first);
    final wizard = Wizard.of(tester.element(firstPage));

    // 1st
    expect(wizard.hasPrevious, isFalse);
    expect(wizard.hasNext, isTrue);

    // 2nd
    wizard.next();
    await tester.pumpAndSettle();

    expect(wizard.hasPrevious, isTrue);
    expect(wizard.hasNext, isTrue);

    // 3rd
    wizard.next();
    await tester.pumpAndSettle();

    expect(wizard.hasPrevious, isTrue);
    expect(wizard.hasNext, isFalse);
  });

  testWidgets('return result', (tester) async {
    await pumpWizardApp(
      tester,
      routes: {
        Routes.first: WizardRoute(builder: (_) => const Text(Routes.first)),
        Routes.second: WizardRoute(builder: (_) => const Text(Routes.second)),
      },
    );

    final firstPage = find.text(Routes.first);
    final firstWizardScope = Wizard.of(tester.element(firstPage));
    expect(firstWizardScope.arguments, isNull);

    final result = firstWizardScope.next();
    await tester.pumpAndSettle();

    final secondPage = find.text(Routes.second);
    final secondWizardScope = Wizard.of(tester.element(secondPage));
    secondWizardScope.back('result');
    expect(await result, equals('result'));
  });
}
