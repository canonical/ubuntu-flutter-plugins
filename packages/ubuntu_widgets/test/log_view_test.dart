import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';

void main() {
  testWidgets('append lines', (tester) async {
    final log = StreamController<String>(sync: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LogView(log: log.stream, maxLines: 2),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));

    final controller = textField.controller;
    expect(controller, isNotNull);

    final scrollController = textField.scrollController;
    expect(scrollController, isNotNull);

    log.add('line 1');
    await tester.pump();
    expect(controller!.text, equals('line 1'));
    expect(scrollController!.position.extentAfter, equals(0.0));
    expect(scrollController.position.maxScrollExtent, equals(0.0));

    log.add('line 2');
    await tester.pump();
    expect(controller.text, equals('line 1\nline 2'));
    expect(scrollController.position.extentAfter, equals(0.0));
    expect(scrollController.position.maxScrollExtent, equals(0.0));

    log.add('line 3');
    await tester.pump();
    expect(controller.text, equals('line 1\nline 2\nline 3'));
    expect(scrollController.position.extentAfter, equals(0.0));
    expect(scrollController.position.maxScrollExtent, greaterThan(0.0));
  });

  testWidgets('rebuild with different stream', (tester) async {
    Future<void> pumpLog(Stream<String> log) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogView(log: log),
          ),
        ),
      );
    }

    final oldLog = StreamController<String>.broadcast(sync: true);
    await pumpLog(oldLog.stream);

    final newLog = StreamController<String>.broadcast(sync: true);
    await pumpLog(newLog.stream);

    final textField = tester.widget<TextField>(find.byType(TextField));

    final controller = textField.controller;
    expect(controller, isNotNull);

    newLog.add('foo');
    expect(controller!.text, equals('foo'));
  });

  testWidgets('do not attempt to scroll when unmounted', (tester) async {
    final log = StreamController<String>.broadcast(sync: true);
    for (int i = 0; i < 3; ++i) {
      log.add('test');
    }

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: LogView(log: log.stream, maxLines: 2))),
    );

    FlutterErrorDetails? error;
    FlutterError.onError = (details) => error = details;
    addTearDown(() => FlutterError.onError = null);

    // trigger a rebuild and destroy the log view. the asynchronous post-frame
    // callback must not attempt to scroll an unmounted widget
    log.add('test');

    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    expect(error, isNull);
  });

  testWidgets('user scroll not affected by appended lines', (tester) async {
    final log = StreamController<String>(sync: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LogView(log: log.stream, maxLines: 2),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));

    final controller = textField.controller;
    expect(controller, isNotNull);

    final scrollController = textField.scrollController;
    expect(scrollController, isNotNull);

    for (int i = 1; i < 6; i++) {
      log.add('line $i');
      await tester.pump();
    }
    expect(controller!.text, equals('line 1\nline 2\nline 3\nline 4\nline 5'));
    expect(scrollController!.offset, greaterThan(0.0));
    expect(scrollController.position.extentAfter, equals(0.0));
    expect(scrollController.position.maxScrollExtent, greaterThan(0.0));

    // moving scroll manually
    scrollController.jumpTo(0.0);
    await tester.pump();
    _scrollOffsetShouldStayAt0(scrollController);

    log.add('line 6');
    await tester.pump();
    expect(
      controller.text,
      equals('line 1\nline 2\nline 3\nline 4\nline 5\nline 6'),
    );
    _scrollOffsetShouldStayAt0(scrollController);
  });
}

void _scrollOffsetShouldStayAt0(ScrollController scrollController) {
  expect(scrollController.offset, equals(0.0));
  expect(scrollController.position.extentAfter, greaterThan(0.0));
  expect(scrollController.position.maxScrollExtent, greaterThan(0.0));
}
