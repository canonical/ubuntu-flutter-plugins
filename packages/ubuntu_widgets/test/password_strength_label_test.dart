import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_localizations/ubuntu_localizations.dart';
import 'package:ubuntu_widgets/src/password_strength_label.dart';
import 'package:yaru/yaru.dart';

void main() {
  test('estimate password strength', () {
    expect(estimatePasswordStrength(''), isWeak);
    expect(estimatePasswordStrength('p'), isWeak);

    // 2
    expect(estimatePasswordStrength('pw'), isWeak);
    expect(estimatePasswordStrength('p4'), isWeak);
    expect(estimatePasswordStrength('p@'), isWeak);

    // 6
    expect(estimatePasswordStrength('passwd'), isWeak);
    expect(estimatePasswordStrength('p4sswd'), isWeak);
    expect(estimatePasswordStrength('p@sswd'), isWeak);

    // 8
    expect(estimatePasswordStrength('password'), isWeak);
    expect(estimatePasswordStrength('Password'), isWeak);
    expect(estimatePasswordStrength('p4ssword'), isWeak);
    expect(estimatePasswordStrength('P4ssword'), isFair);
    expect(estimatePasswordStrength('p@ssw0rd'), isFair);
    expect(estimatePasswordStrength('P@ssw0rd'), isFair);
    expect(estimatePasswordStrength('P@ssw0rD'), isFair);

    // 9
    expect(estimatePasswordStrength('passsword'), isWeak);
    expect(estimatePasswordStrength('p4sssword'), isWeak);
    expect(estimatePasswordStrength('P4sssword'), isFair);
    expect(estimatePasswordStrength('p@sssword'), isGood);
    expect(estimatePasswordStrength('P@sssword'), isGood);
    expect(estimatePasswordStrength('p@sssw0rd'), isGood);
    expect(estimatePasswordStrength('P@sssw0rd'), isGood);
    expect(estimatePasswordStrength('P@555w0rD'), isGood);

    expect(estimatePasswordStrength('321Dr0w55@P'), isStrong);
    expect(estimatePasswordStrength('y42JU%#agK%kj64'), isStrong);
  });

  testWidgets('weak password', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: UbuntuLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) {
            return const PasswordStrengthLabel(strength: PasswordStrength.weak);
          },
        ),
      ),
    );

    final context = tester.element(find.byType(PasswordStrengthLabel));

    final text = UbuntuLocalizations.of(context).weakPassword;
    expect(find.text(text), findsOneWidget);

    final widget = tester.widget<Text>(find.text(text));
    expect(widget.style?.color, isNotNull);
    expect(widget.style!.color, equals(Theme.of(context).colorScheme.error));
  });

  testWidgets('fair password', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: UbuntuLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) {
            return const PasswordStrengthLabel(strength: PasswordStrength.fair);
          },
        ),
      ),
    );

    final context = tester.element(find.byType(PasswordStrengthLabel));
    final text = UbuntuLocalizations.of(context).fairPassword;
    expect(find.text(text), findsOneWidget);

    final widget = tester.widget<Text>(find.text(text));
    expect(widget.style?.color, isNull);
  });

  testWidgets('good password', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: UbuntuLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) {
            return const PasswordStrengthLabel(strength: PasswordStrength.good);
          },
        ),
      ),
    );

    final context = tester.element(find.byType(PasswordStrengthLabel));
    final text = UbuntuLocalizations.of(context).goodPassword;
    expect(find.text(text), findsOneWidget);

    final widget = tester.widget<Text>(find.text(text));
    expect(widget.style?.color, isNull);
  });

  testWidgets('strong password', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: UbuntuLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) {
            return const PasswordStrengthLabel(
                strength: PasswordStrength.strong,);
          },
        ),
      ),
    );

    final context = tester.element(find.byType(PasswordStrengthLabel));

    final text = UbuntuLocalizations.of(context).strongPassword;
    expect(find.text(text), findsOneWidget);

    final widget = tester.widget<Text>(find.text(text));
    expect(widget.style?.color, isNotNull);
    expect(widget.style!.color, equals(Theme.of(context).colorScheme.success));
  });
}

const Matcher isWeak = PasswordStrengthMatcher(PasswordStrength.weak);
const Matcher isFair = PasswordStrengthMatcher(PasswordStrength.fair);
const Matcher isGood = PasswordStrengthMatcher(PasswordStrength.good);
const Matcher isStrong = PasswordStrengthMatcher(PasswordStrength.strong);

class PasswordStrengthMatcher extends Matcher {
  const PasswordStrengthMatcher(this.strength);

  final PasswordStrength strength;

  @override
  bool matches(dynamic item, _) => item == strength;

  @override
  Description describe(Description description) =>
      description.add(strength.toString());
}
