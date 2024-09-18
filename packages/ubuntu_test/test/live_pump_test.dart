import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_test/ubuntu_test.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pump until', (tester) async {
    final loading = ValueNotifier(true);

    await tester.pumpWidget(MaterialApp(
      home: ValueListenableBuilder(
        valueListenable: loading,
        builder: (context, value, child) {
          Timer(const Duration(milliseconds: 250), () => loading.value = false);
          return value ? const Text('loading...') : const Text('home');
        },
      ),
    ),);

    expect(find.text('loading...'), findsOneWidget);
    expect(find.text('home'), findsNothing);

    await tester.pumpUntil(find.text('home'));

    expect(find.text('loading...'), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('pump timeout', (tester) async {
    final loading = ValueNotifier(true);

    await tester.pumpWidget(MaterialApp(
      home: ValueListenableBuilder(
        valueListenable: loading,
        builder: (context, value, child) {
          Timer(const Duration(seconds: 5), () => loading.value = false);
          return value ? const Text('loading...') : const Text('home');
        },
      ),
    ),);

    expect(find.text('loading...'), findsOneWidget);
    expect(find.text('home'), findsNothing);

    await expectLater(
      () => tester.pumpUntil(
          find.text('home'), const Duration(milliseconds: 250),),
      throwsA(isA<TestFailure>()),
    );

    expect(find.text('loading...'), findsOneWidget);
    expect(find.text('home'), findsNothing);
  });

  testWidgets('run app', (tester) async {
    final onError = FlutterError.onError;
    await tester.runApp(() => FlutterError.onError = (details) {});
    expect(FlutterError.onError, onError);
  });
}
