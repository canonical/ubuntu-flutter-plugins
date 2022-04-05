import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';

enum TestEnum { foo, bar, baz }

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('builds an item for each value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: MenuButtonBuilder<TestEnum>(
            selected: TestEnum.bar,
            values: TestEnum.values,
            onSelected: (_) {},
            iconBuilder: (_, value, __) => const Icon(Icons.arrow_drop_down),
            itemBuilder: (_, value, __) => Text(value.toString()),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<TestEnum>));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    for (final value in TestEnum.values) {
      expect(find.text(value.toString()), findsOneWidget);
    }
  });

  testWidgets('selects initial value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: MenuButtonBuilder<TestEnum>(
            selected: TestEnum.bar,
            values: TestEnum.values,
            onSelected: (_) {},
            iconBuilder: (_, value, __) => const Icon(Icons.arrow_drop_down),
            itemBuilder: (_, value, __) => Text(value.toString()),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<TestEnum>));
    await tester.pumpAndSettle();

    final item = find.ancestor(
      of: find.text(TestEnum.bar.toString()),
      matching: find.byType(CheckedPopupMenuItem<TestEnum>),
    );
    expect(tester.widget<CheckedPopupMenuItem<TestEnum>>(item).checked, isTrue);
  });

  testWidgets('selects tapped value', (tester) async {
    TestEnum? selectedValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: MenuButtonBuilder<TestEnum>(
            selected: TestEnum.bar,
            values: TestEnum.values,
            onSelected: (value) => selectedValue = value,
            iconBuilder: (_, value, __) => const Icon(Icons.arrow_drop_down),
            itemBuilder: (_, value, __) => Text(value.toString()),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<TestEnum>));
    await tester.pumpAndSettle();

    await tester.tap(find.text(TestEnum.baz.toString()).last);
    await tester.pumpAndSettle();

    expect(selectedValue, equals(TestEnum.baz));
  });
}
