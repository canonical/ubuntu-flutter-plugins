import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru_test/yaru_test.dart';

void main() {
  testWidgets('elevated', (tester) async {
    bool? wasPressed;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: PushButton.elevated(
            onPressed: () => wasPressed = true,
            child: const Text('elevated'),
          ),
        ),
      ),
    );

    expect(find.bySubtype<ElevatedButton>(), findsOneWidget);

    final box = find.descendant(
      of: find.button('elevated'),
      matching: find.byType(ConstrainedBox),
    );
    expect(
      tester.widget<ConstrainedBox>(box).constraints,
      isA<BoxConstraints>()
          .having((c) => c.minWidth, 'minWidth', kPushButtonSize.width)
          .having((c) => c.minHeight, 'minHeight', kPushButtonSize.height),
    );

    await tester.tapButton('elevated');
    expect(wasPressed, isTrue);
  });

  testWidgets('filled', (tester) async {
    bool? wasPressed;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: PushButton.filled(
            onPressed: () => wasPressed = true,
            child: const Text('filled'),
          ),
        ),
      ),
    );

    expect(find.bySubtype<FilledButton>(), findsOneWidget);

    final box = find.descendant(
      of: find.button('filled'),
      matching: find.byType(ConstrainedBox),
    );
    expect(
      tester.widget<ConstrainedBox>(box).constraints,
      isA<BoxConstraints>()
          .having((c) => c.minWidth, 'minWidth', kPushButtonSize.width)
          .having((c) => c.minHeight, 'minHeight', kPushButtonSize.height),
    );

    await tester.tapButton('filled');
    expect(wasPressed, isTrue);
  });

  testWidgets('outlined', (tester) async {
    bool? wasPressed;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: PushButton.outlined(
            onPressed: () => wasPressed = true,
            child: const Text('outlined'),
          ),
        ),
      ),
    );

    expect(find.bySubtype<OutlinedButton>(), findsOneWidget);

    final box = find.descendant(
      of: find.button('outlined'),
      matching: find.byType(ConstrainedBox),
    );
    expect(
      tester.widget<ConstrainedBox>(box).constraints,
      isA<BoxConstraints>()
          .having((c) => c.minWidth, 'minWidth', kPushButtonSize.width)
          .having((c) => c.minHeight, 'minHeight', kPushButtonSize.height),
    );

    await tester.tapButton('outlined');
    expect(wasPressed, isTrue);
  });
}
