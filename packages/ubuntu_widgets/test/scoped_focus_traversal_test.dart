import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';

void main() {
  testWidgets('tab focus', (tester) async {
    final button1Node = FocusNode();
    final button2Node = FocusNode();
    final itemNodes = [for (var i = 0; i < 10; ++i) FocusNode()];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            ElevatedButton(
              focusNode: button1Node,
              onPressed: () {},
              child: const SizedBox.shrink(),
            ),
            Expanded(
              child: ScopedFocusTraversalGroup(
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ScopedFocusTraversalOrder(
                      focus: index == 5,
                      child: ListTile(
                        focusNode: itemNodes[index],
                        onTap: () {},
                      ),
                    );
                  },
                ),
              ),
            ),
            ElevatedButton(
              focusNode: button2Node,
              onPressed: () {},
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    ));

    expect(button1Node.hasFocus, isFalse);
    expect(itemNodes.every((node) => node.hasFocus), isFalse);
    expect(button2Node.hasFocus, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(button1Node.hasFocus, isTrue);
    expect(itemNodes.every((node) => node.hasFocus), isFalse);
    expect(button2Node.hasFocus, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(button1Node.hasFocus, isFalse);
    expect(itemNodes[5].hasFocus, isTrue);
    expect(button2Node.hasFocus, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(button1Node.hasFocus, isFalse);
    expect(itemNodes.every((node) => node.hasFocus), isFalse);
    expect(button2Node.hasFocus, isTrue);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    addTearDown(() => tester.sendKeyUpEvent(LogicalKeyboardKey.shift));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(button1Node.hasFocus, isFalse);
    expect(itemNodes[5].hasFocus, isTrue);
    expect(button2Node.hasFocus, isFalse);
  });

  testWidgets('key navigation', (tester) async {
    final button1Node = FocusNode();
    final button2Node = FocusNode();
    final itemNodes = [for (var i = 0; i < 10; ++i) FocusNode()];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            ElevatedButton(
              focusNode: button1Node,
              onPressed: () {},
              child: const SizedBox.shrink(),
            ),
            Expanded(
              child: ScopedFocusTraversalGroup(
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ScopedFocusTraversalOrder(
                      focus: index == 3,
                      child: ListTile(
                        autofocus: index == 3,
                        focusNode: itemNodes[index],
                        onTap: () {},
                      ),
                    );
                  },
                ),
              ),
            ),
            ElevatedButton(
              focusNode: button2Node,
              onPressed: () {},
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    ));

    expect(itemNodes[3].hasFocus, isTrue);

    for (var i = 2; i >= 0; --i) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      expect(itemNodes[i + 1].hasFocus, isFalse);
      expect(itemNodes[i].hasFocus, isTrue);
    }

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    expect(itemNodes[0].hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(itemNodes[0].hasFocus, isFalse);
    expect(itemNodes[1].hasFocus, isTrue);

    for (var i = 2; i < 10; ++i) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(itemNodes[i - 1].hasFocus, isFalse);
      expect(itemNodes[i].hasFocus, isTrue);
    }

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(itemNodes[9].hasFocus, isTrue);
  });

  testWidgets('first focus up', (tester) async {
    final itemNodes = [for (var i = 0; i < 10; ++i) FocusNode()];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ScopedFocusTraversalGroup(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return ScopedFocusTraversalOrder(
                focus: index == 5,
                child: ListTile(
                  focusNode: itemNodes[index],
                  onTap: () {},
                ),
              );
            },
          ),
        ),
      ),
    ));

    expect(itemNodes.every((node) => node.hasFocus), isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    expect(itemNodes.last.hasFocus, isTrue);
  });

  testWidgets('first focus down', (tester) async {
    final itemNodes = [for (var i = 0; i < 10; ++i) FocusNode()];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ScopedFocusTraversalGroup(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return ScopedFocusTraversalOrder(
                focus: index == 5,
                child: ListTile(
                  focusNode: itemNodes[index],
                  onTap: () {},
                ),
              );
            },
          ),
        ),
      ),
    ));

    expect(itemNodes.every((node) => node.hasFocus), isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(itemNodes.first.hasFocus, isTrue);
  });
}
