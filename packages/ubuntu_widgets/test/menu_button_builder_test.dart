import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';

enum TestEnum { foo, bar, baz }

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('uses child if supplied', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: MenuButtonBuilder<TestEnum>(
            selected: TestEnum.bar,
            entries:
                TestEnum.values.map((e) => MenuButtonEntry(value: e)).toList(),
            onSelected: (_) {},
            itemBuilder: (_, value, __) => Text(value.name),
            child: const Text('child'),
          ),
        ),
      ),
    );

    expect(find.text(TestEnum.bar.name), findsNothing);
    expect(find.text('child'), findsOneWidget);
  });

  testWidgets('builds a selected item', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: MenuButtonBuilder<TestEnum>(
            selected: TestEnum.bar,
            entries:
                TestEnum.values.map((e) => MenuButtonEntry(value: e)).toList(),
            onSelected: (_) {},
            itemBuilder: (_, value, __) => Text(value.name),
          ),
        ),
      ),
    );

    expect(find.text(TestEnum.bar.name), findsOneWidget);
  });

  testWidgets('builds an item for each value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: MenuButtonBuilder<TestEnum>(
            entries:
                TestEnum.values.map((e) => MenuButtonEntry(value: e)).toList(),
            onSelected: (_) {},
            iconBuilder: (_, value, __) => const Icon(Icons.arrow_drop_down),
            itemBuilder: (_, value, __) => Text(value.toString()),
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    await tester.tap(find.bySubtype<ButtonStyleButton>());
    await tester.pumpAndSettle();

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
            entries:
                TestEnum.values.map((e) => MenuButtonEntry(value: e)).toList(),
            onSelected: (_) {},
            iconBuilder: (_, value, __) => const Icon(Icons.arrow_drop_down),
            itemBuilder: (_, value, __) => Text(value.toString()),
          ),
        ),
      ),
    );

    await tester.tap(find.bySubtype<ButtonStyleButton>());
    await tester.pumpAndSettle();

    final item = find.ancestor(
      of: find.text(TestEnum.bar.toString()),
      matching: find.byType(MenuItemButton),
    );
    expect(tester.widget<MenuItemButton>(item).focusNode?.hasFocus, isTrue);
  });

  testWidgets('selects tapped value', (tester) async {
    TestEnum? selectedValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: MenuButtonBuilder<TestEnum>(
            selected: TestEnum.bar,
            entries:
                TestEnum.values.map((e) => MenuButtonEntry(value: e)).toList(),
            onSelected: (value) => selectedValue = value,
            iconBuilder: (_, value, __) => const Icon(Icons.arrow_drop_down),
            itemBuilder: (_, value, __) => Text(value.toString()),
          ),
        ),
      ),
    );

    await tester.tap(find.bySubtype<ButtonStyleButton>());
    await tester.pumpAndSettle();

    await tester.tap(find.text(TestEnum.baz.toString()).last);
    await tester.pumpAndSettle();

    expect(selectedValue, equals(TestEnum.baz));
  });
}
