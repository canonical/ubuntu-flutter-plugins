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
          child: DropdownBuilder<TestEnum>(
            values: TestEnum.values,
            onSelected: (_) {},
            itemBuilder: (_, value, __) => Text(value.toString()),
          ),
        ),
      ),
    );

    for (final value in TestEnum.values) {
      expect(find.text(value.toString()), findsOneWidget);
    }
  });

  testWidgets('selects initial value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DropdownBuilder<TestEnum>(
            selected: TestEnum.baz,
            values: TestEnum.values,
            onSelected: (value) {},
            itemBuilder: (_, value, __) => Text(value.toString()),
          ),
        ),
      ),
    );

    final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
    expect(stack.index, equals(2));
  });

  testWidgets('selects tapped value', (tester) async {
    TestEnum? selectedValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DropdownBuilder<TestEnum>(
            values: TestEnum.values,
            onSelected: (value) => selectedValue = value,
            itemBuilder: (_, value, __) => Text(value.toString()),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<TestEnum>));
    await tester.pumpAndSettle();

    await tester.tap(find.text(TestEnum.bar.toString()).last);
    await tester.pumpAndSettle();

    expect(selectedValue, equals(TestEnum.bar));
  });

  testWidgets('allows null value', (tester) async {
    int? selectedValue = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DropdownBuilder<int?>(
            values: const [1, 2, 3, null],
            onSelected: (value) => selectedValue = value,
            itemBuilder: (_, value, __) => Text(value.toString()),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<int?>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('null').last);
    await tester.pumpAndSettle();

    expect(selectedValue, isNull);
  });

  testWidgets('disabled', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DropdownBuilder<String>(
            selected: 'foo',
            values: const ['foo', 'bar', 'baz'],
            onSelected: null,
            itemBuilder: (_, value, __) => Text(value),
          ),
        ),
      ),
    );

    final button = find.byType(DropdownButton<String>);
    expect(tester.widget<DropdownButton<String>>(button).onChanged, isNull);
  });
}
