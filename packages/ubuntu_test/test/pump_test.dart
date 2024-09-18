import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_test/ubuntu_test.dart';

void main() {
  AutomatedTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pump until throws', (tester) async {
    await tester.pumpWidget(const MaterialApp());

    await expectLater(
      tester.pumpUntil(find.byType(MaterialApp)),
      throwsAssertionError,
    );
  });
}
