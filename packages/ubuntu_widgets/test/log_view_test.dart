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
