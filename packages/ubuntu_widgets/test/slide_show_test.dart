import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';

extension AppTester on WidgetTester {
  Future<void> pumpTestApp({
    required List<String> slides,
    Duration? interval,
    bool wrap = false,
    bool autofocus = false,
    ValueChanged<int>? onSlide,
  }) {
    return pumpWidget(
      MaterialApp(
        home: SlideShow(
          interval: interval ?? const Duration(seconds: 5),
          slides: slides.map(Text.new).toList(),
          wrap: wrap,
          autofocus: autofocus,
          onSlide: onSlide,
        ),
      ),
    );
  }
}

void main() {
  testWidgets('structure', (tester) async {
    await tester.pumpTestApp(slides: ['Slide'], wrap: true);

    expect(find.text('Slide'), findsNWidgets(2)); // +1 for size
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('buttons', (tester) async {
    await tester.pumpTestApp(slides: ['a', 'b', 'c']);

    expect(find.text('a'), findsNWidgets(2));
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('b'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('c'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('b'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('a'), findsNWidgets(2));
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('arrow keys', (tester) async {
    await tester.pumpTestApp(slides: ['a', 'b', 'c'], autofocus: true);

    expect(find.text('a'), findsNWidgets(2));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('b'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('c'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('b'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('a'), findsNWidgets(2));
  });

  testWidgets('interval', (tester) async {
    await tester.pumpTestApp(
      slides: ['a', 'b', 'c'],
      interval: const Duration(seconds: 5),
    );

    expect(find.text('a'), findsNWidgets(2));

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('a'), findsNWidgets(2));

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('b'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('c'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('c'), findsOneWidget);
  });

  testWidgets('timer', (tester) async {
    await tester.pumpTestApp(
      slides: ['a', 'b', 'c'],
      interval: const Duration(seconds: 5),
    );

    expect(find.text('a'), findsNWidgets(2));

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('a'), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('b'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('b'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('c'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('c'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('b'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('b'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('c'), findsOneWidget);
  });

  testWidgets('wrap', (tester) async {
    await tester.pumpTestApp(slides: ['a', 'b', 'c'], wrap: true);

    expect(find.text('a'), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('b'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('c'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('a'), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('c'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('b'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('a'), findsNWidgets(2));
  });

  testWidgets('callback', (tester) async {
    int? slide;
    await tester.pumpTestApp(
      slides: ['a', 'b', 'c'],
      interval: const Duration(seconds: 1),
      wrap: true,
      onSlide: (index) => slide = index,
    );

    expect(find.text('a'), findsNWidgets(2));
    expect(slide, isNull);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('b'), findsOneWidget);
    expect(slide, 1);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('c'), findsOneWidget);
    expect(slide, 2);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('a'), findsNWidgets(2));
    expect(slide, 0);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('c'), findsOneWidget);
    expect(slide, 2);
  });
}
