import 'package:flutter/material.dart';
import 'package:password_strength/password_strength.dart' as pws;
import 'package:ubuntu_localizations/ubuntu_localizations.dart';
import 'package:yaru/yaru.dart';

/// The strength of a password.
enum PasswordStrength {
  /// A weak password.
  weak,

  /// A fair password.
  fair,

  /// A good password.
  good,

  /// A strong password.
  strong,
}

/// Estimates the strength of the given [password].
PasswordStrength estimatePasswordStrength(String password) {
  final strength = pws.estimatePasswordStrength(password);
  if (strength < 0.5) {
    return PasswordStrength.weak;
  } else if (strength < 0.75) {
    return PasswordStrength.fair;
  } else if (strength < 0.9) {
    return PasswordStrength.good;
  } else {
    return PasswordStrength.strong;
  }
}

/// A widget that visualizes the strength of a password.
class PasswordStrengthLabel extends StatelessWidget {
  /// Creates a new label with the given [strength].
  const PasswordStrengthLabel({required this.strength, super.key});

  /// The strength of the password.
  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final lang = UbuntuLocalizations.of(context);
    switch (strength) {
      case PasswordStrength.weak:
        return Text(
          lang.weakPassword,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        );
      case PasswordStrength.fair:
        return Text(lang.fairPassword);
      case PasswordStrength.good:
        return Text(lang.goodPassword);
      case PasswordStrength.strong:
        return Text(
          lang.strongPassword,
          style: TextStyle(color: Theme.of(context).colorScheme.success),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
