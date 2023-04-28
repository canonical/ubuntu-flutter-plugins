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

class TestObserver extends WizardObserver {
  Route? init;
  Route? nextTo;
  Route? nextFrom;
  Route? backTo;
  Route? backFrom;
  Object? result;

  void reset() {
    init = null;
    nextTo = null;
    nextFrom = null;
    backTo = null;
    backFrom = null;
    result = null;
  }

  @override
  void onInit(Route route) {
    init = route;
  }

  @override
  void onNext(Route route, Route? previousRoute) {
    nextTo = route;
    nextFrom = previousRoute;
  }

  @override
  void onBack(Route route, Route previousRoute) {
    backTo = route;
    backFrom = previousRoute;
  }
}

void main() {
  Future<void> pumpWizardApp(
    WidgetTester tester, {
    String? initialRoute,
    Map<String, WizardRoute>? routes,
    Object? userData,
    WizardController? controller,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Wizard(
          initialRoute: initialRoute,
          routes: routes,
          userData: userData,
          controller: controller,
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

  testWidgets('available in context', (tester) async {
    await expectLater(
      () => pumpWizardApp(
        tester,
        routes: {
          '/': WizardRoute(builder: (context) => Text('${Wizard.of(context)}')),
        },
      ),
      returnsNormally,
    );
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
    await expectLater(wizard.next, throwsAssertionError);

    wizard.back();
    wizard.back();
    await expectLater(wizard.back, throwsAssertionError);
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
    await expectLater(firstWizardScope.next, throwsAssertionError);

    nextRoute = Routes.second;
    firstWizardScope.next();
    await tester.pumpAndSettle();

    final secondWizardScope = Wizard.of(tester.element(secondPage));
    backRoute = 'invalid';
    await expectLater(secondWizardScope.back, throwsAssertionError);
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
    await expectLater(wizard.home, throwsAssertionError);

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

  testWidgets('replace', (tester) async {
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

    firstWizardScope.replace();
    await tester.pumpAndSettle();

    expect(firstPage, findsNothing);
    expect(secondPage, findsOneWidget);
    expect(thirdPage, findsNothing);

    expect(firstWizardScope.mounted, isFalse);

    final secondWizardScope = Wizard.of(tester.element(secondPage));
    expect(secondWizardScope, isNotNull);
    expect(secondWizardScope.hasPrevious, isFalse);
    expect(secondWizardScope.hasNext, isTrue);

    // 2nd -> 1st
    await expectLater(secondWizardScope.back, throwsAssertionError);

    // 2nd -> 3rd
    secondWizardScope.replace();
    await tester.pumpAndSettle();

    expect(firstPage, findsNothing);
    expect(secondPage, findsNothing);
    expect(thirdPage, findsOneWidget);

    expect(secondWizardScope.mounted, isFalse);

    final thirdWizardScope = Wizard.of(tester.element(thirdPage));
    expect(thirdWizardScope, isNotNull);
    expect(thirdWizardScope.hasPrevious, isFalse);
    expect(thirdWizardScope.hasNext, isFalse);

    // 3rd -> 2nd
    await expectLater(thirdWizardScope.back, throwsAssertionError);
  });

  testWidgets('jump', (tester) async {
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

    // 1st -> 3rd
    final firstWizardScope = Wizard.of(tester.element(firstPage));
    expect(firstWizardScope, isNotNull);
    expect(firstWizardScope.hasPrevious, isFalse);
    expect(firstWizardScope.hasNext, isTrue);

    firstWizardScope.jump(Routes.third);
    await tester.pumpAndSettle();

    expect(firstPage, findsNothing);
    expect(secondPage, findsNothing);
    expect(thirdPage, findsOneWidget);

    // 3rd -> 1st
    final thirdWizardScope = Wizard.of(tester.element(thirdPage));
    expect(thirdWizardScope, isNotNull);
    expect(thirdWizardScope.hasPrevious, isTrue);
    expect(thirdWizardScope.hasNext, isFalse);

    thirdWizardScope.back();
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
    final firstScope = Wizard.of(tester.element(firstPage));

    // 1st
    expect(firstScope.hasPrevious, isFalse);
    expect(firstScope.hasNext, isTrue);

    // 2nd
    firstScope.next();
    await tester.pumpAndSettle();

    final secondPage = find.text(Routes.second);
    final secondScope = Wizard.of(tester.element(secondPage));

    expect(secondScope.hasPrevious, isTrue);
    expect(secondScope.hasNext, isTrue);

    // 3rd
    secondScope.next();
    await tester.pumpAndSettle();

    final thirdPage = find.text(Routes.third);
    final thirdScope = Wizard.of(tester.element(thirdPage));

    expect(thirdScope.hasPrevious, isTrue);
    expect(thirdScope.hasNext, isFalse);
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

  testWidgets('throw exception for missing wizard', (tester) async {
    await tester.pumpWidget(const MaterialApp());

    final context = tester.element(find.byType(MaterialApp));
    expect(context, isNotNull);

    expect(() => Wizard.of(context), throwsFlutterError);
  });

  testWidgets('observers', (tester) async {
    final observer = TestObserver();
    await tester.pumpWidget(
      MaterialApp(
        home: Wizard(
          initialRoute: Routes.first,
          routes: {
            Routes.first: WizardRoute(builder: (_) => const Text(Routes.first)),
            Routes.second:
                WizardRoute(builder: (_) => const Text(Routes.second)),
            Routes.third: WizardRoute(builder: (_) => const Text(Routes.third)),
          },
          observers: [observer],
        ),
      ),
    );

    expect(observer.init?.settings.name, Routes.first);
    expect(observer.nextFrom, isNull);
    expect(observer.nextTo, isNull);
    expect(observer.backFrom, isNull);
    expect(observer.backTo, isNull);
    observer.reset();

    Wizard.of(tester.element(find.text(Routes.first))).next();
    await tester.pumpAndSettle();

    expect(observer.nextFrom?.settings.name, Routes.first);
    expect(observer.nextTo?.settings.name, Routes.second);
    expect(observer.backFrom, isNull);
    expect(observer.backTo, isNull);
    expect(observer.init, isNull);
    observer.reset();

    Wizard.of(tester.element(find.text(Routes.second))).replace();
    await tester.pumpAndSettle();

    expect(observer.nextFrom?.settings.name, Routes.second);
    expect(observer.nextTo?.settings.name, Routes.third);
    expect(observer.backFrom, isNull);
    expect(observer.backTo, isNull);
    expect(observer.init, isNull);
    observer.reset();

    Wizard.of(tester.element(find.text(Routes.third))).back();
    await tester.pumpAndSettle();

    expect(observer.backFrom?.settings.name, Routes.third);
    expect(observer.backTo?.settings.name, Routes.first);
    expect(observer.nextFrom, isNull);
    expect(observer.nextTo, isNull);
    expect(observer.init, isNull);
    observer.reset();
  });

  testWidgets('maybe of', (tester) async {
    await pumpWizardApp(
      tester,
      routes: {
        Routes.first: WizardRoute(builder: (_) => const Text(Routes.first)),
      },
    );

    expect(Wizard.maybeOf(tester.element(find.byType(MaterialApp))), isNull);
    expect(Wizard.maybeOf(tester.element(find.text(Routes.first))), isNotNull);
    expect(Wizard.maybeOf(tester.element(find.text(Routes.first))),
        Wizard.of(tester.element(find.text(Routes.first))));
  });

  testWidgets('hasNext returns false for the last route', (tester) async {
    await pumpWizardApp(
      tester,
      initialRoute: Routes.second,
      routes: {
        Routes.first: WizardRoute(builder: (_) => const Text(Routes.first)),
        Routes.second: WizardRoute(
          builder: (context) => ElevatedButton(
            child: const Text(Routes.second),
            onPressed: () {
              final wiz = Wizard.of(context);
              if (wiz.hasNext) wiz.next();
            },
          ),
        ),
        Routes.third: WizardRoute(
          builder: (context) => TextButton(
            child: const Text(Routes.third),
            onPressed: () {
              final wiz = Wizard.of(context);
              // Third should never call next() because it's the last route.
              if (wiz.hasNext) wiz.next();
            },
          ),
        ),
      },
    );

    // We are on the second route.
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    //Now we should be on the third
    expect(find.text(Routes.first), findsNothing);
    expect(find.text(Routes.second), findsNothing);
    expect(find.text(Routes.third), findsOneWidget);

    // Nothing should happen now:
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text(Routes.first), findsNothing);
    expect(find.text(Routes.second), findsNothing);
    expect(find.text(Routes.third), findsOneWidget);
  });

  testWidgets('hasNext returns false for the last route on skip as well',
      (tester) async {
    await pumpWizardApp(
      tester,
      initialRoute: Routes.first,
      routes: {
        Routes.first: WizardRoute(
          builder: (context) => ElevatedButton(
            child: const Text(Routes.first),
            onPressed: () {
              final wiz = Wizard.of(context);
              if (wiz.hasNext) wiz.next();
            },
          ),
          //skipping the second.
          onNext: (_) => Routes.third,
        ),
        Routes.second: WizardRoute(builder: (_) => const Text(Routes.second)),
        Routes.third: WizardRoute(
          builder: (context) => TextButton(
            child: const Text(Routes.third),
            onPressed: () {
              final wiz = Wizard.of(context);
              // Third should never call next() because it's the last route.
              if (wiz.hasNext) wiz.next();
            },
          ),
        ),
      },
    );

    // We are on the first route.
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    //Now we should be on the third
    expect(find.text(Routes.first), findsNothing);
    expect(find.text(Routes.second), findsNothing);
    expect(find.text(Routes.third), findsOneWidget);

    // Nothing should happen now:
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text(Routes.first), findsNothing);
    expect(find.text(Routes.second), findsNothing);
    expect(find.text(Routes.third), findsOneWidget);
  });

  testWidgets('rebuild with different routes', (tester) async {
    await pumpWizardApp(
      tester,
      routes: {
        Routes.first: WizardRoute(builder: (_) => const Text(Routes.first)),
        Routes.second: WizardRoute(builder: (_) => const Text(Routes.second)),
        Routes.third: WizardRoute(builder: (_) => const Text(Routes.third)),
      },
    );
    await tester.pumpAndSettle();

    expect(find.text(Routes.first), findsOneWidget);
    expect(find.text(Routes.second), findsNothing);
    expect(find.text(Routes.third), findsNothing);

    await pumpWizardApp(
      tester,
      routes: {
        Routes.second: WizardRoute(builder: (_) => const Text(Routes.second)),
        Routes.third: WizardRoute(builder: (_) => const Text(Routes.third)),
      },
    );
    await tester.pumpAndSettle();

    expect(find.text(Routes.first), findsNothing);
    expect(find.text(Routes.second), findsOneWidget);
    expect(find.text(Routes.third), findsNothing);
  });

  testWidgets('user data', (tester) async {
    await pumpWizardApp(
      tester,
      routes: {
        Routes.first: WizardRoute(
          builder: (context) {
            final wizardScope = Wizard.of(context);
            final page = (wizardScope.routeData as Map)['page'] ?? -1;
            final totalPages =
                (wizardScope.wizardData as Map)['totalPages'] ?? -1;
            return Column(
              children: [
                const Text(Routes.first),
                Text('Page $page of $totalPages'),
              ],
            );
          },
          userData: {'page': 1},
        ),
        Routes.second: WizardRoute(
          builder: (_) => const Text(Routes.second),
        ),
      },
      userData: {'totalPages': 3},
    );
    await tester.pumpAndSettle();

    expect(find.text(Routes.first), findsOneWidget);
    expect(find.text(Routes.second), findsNothing);

    expect(find.text('Page 1 of 3'), findsOneWidget);
  });

  testWidgets('nested wizard', (tester) async {
    await pumpWizardApp(
      tester,
      routes: {
        Routes.first: WizardRoute(builder: (_) => const Text(Routes.first)),
        Routes.second: WizardRoute(
          builder: (_) => Wizard(
            routes: {
              'nested1': WizardRoute(builder: (_) => const Text('nested1')),
              'nested2': WizardRoute(builder: (_) => const Text('nested2')),
              'nested3': WizardRoute(builder: (_) => const Text('nested3')),
            },
          ),
        ),
        Routes.third: WizardRoute(builder: (_) => const Text(Routes.third)),
      },
    );
    await tester.pumpAndSettle();

    final firstPage = find.text(Routes.first);
    expect(firstPage, findsOneWidget);

    final firstScope = Wizard.of(tester.element(firstPage));
    expect(firstScope, isNotNull);
    expect(firstScope.hasPrevious, isFalse);
    expect(firstScope.hasNext, isTrue);

    firstScope.next();
    await tester.pumpAndSettle();

    final nested1Page = find.text('nested1');
    expect(nested1Page, findsOneWidget);

    final nested1Scope = Wizard.of(tester.element(nested1Page));
    expect(nested1Scope, isNotNull);
    expect(nested1Scope.hasPrevious, isFalse);
    expect(nested1Scope.hasNext, isTrue);

    final root1Scope = Wizard.of(tester.element(nested1Page), root: true);
    expect(root1Scope, isNotNull);
    expect(root1Scope.hasPrevious, isTrue);
    expect(root1Scope.hasNext, isTrue);

    nested1Scope.next();
    await tester.pumpAndSettle();

    final nested2Page = find.text('nested2');
    expect(nested2Page, findsOneWidget);

    final nested2Scope = Wizard.of(tester.element(nested2Page));
    expect(nested2Scope, isNotNull);
    expect(nested2Scope.hasPrevious, isTrue);
    expect(nested2Scope.hasNext, isTrue);

    final root2Scope = Wizard.of(tester.element(nested2Page), root: true);
    expect(root2Scope, same(root1Scope));
    expect(root2Scope.hasPrevious, isTrue);
    expect(root2Scope.hasNext, isTrue);

    nested2Scope.next();
    await tester.pumpAndSettle();

    final nested3Page = find.text('nested3');
    expect(nested3Page, findsOneWidget);

    final nested3Scope = Wizard.of(tester.element(nested3Page));
    expect(nested3Scope, isNotNull);
    expect(nested3Scope.hasPrevious, isTrue);
    expect(nested3Scope.hasNext, isFalse);

    final root3Scope = Wizard.of(tester.element(nested3Page), root: true);
    expect(root3Scope, same(root1Scope));
    expect(root3Scope.hasPrevious, isTrue);
    expect(root3Scope.hasNext, isTrue);

    await expectLater(nested3Scope.next, throwsAssertionError);

    root3Scope.next();
    await tester.pumpAndSettle();

    final thirdPage = find.text(Routes.third);
    expect(thirdPage, findsOneWidget);

    final thirdScope = Wizard.of(tester.element(thirdPage));
    expect(thirdScope, isNotNull);
    expect(thirdScope.hasPrevious, isTrue);
    expect(thirdScope.hasNext, isFalse);

    thirdScope.back();
    await tester.pumpAndSettle();

    expect(nested3Page, findsOneWidget);

    nested3Scope.back();
    await tester.pumpAndSettle();

    expect(nested2Page, findsOneWidget);

    root2Scope.back();
    await tester.pumpAndSettle();

    expect(firstPage, findsOneWidget);
  });

  testWidgets('controller', (tester) async {
    final controller = WizardController(routes: {
      Routes.first: WizardRoute(builder: (_) => const Text(Routes.first)),
      Routes.second: WizardRoute(builder: (_) => const Text(Routes.second)),
      Routes.third: WizardRoute(builder: (_) => const Text(Routes.third)),
    });

    await pumpWizardApp(
      tester,
      controller: controller,
    );
    await tester.pumpAndSettle();

    controller.next();
    await tester.pumpAndSettle();
    expect(find.text(Routes.second), findsOneWidget);

    controller.replace();
    await tester.pumpAndSettle();
    expect(find.text(Routes.third), findsOneWidget);

    controller.back();
    await tester.pumpAndSettle();
    expect(find.text(Routes.first), findsOneWidget);
  });
}
