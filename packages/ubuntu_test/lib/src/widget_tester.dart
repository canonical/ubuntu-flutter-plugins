import 'package:flutter_test/flutter_test.dart';
import 'package:yaru_test/yaru_test.dart';

import 'common_finders.dart';

/// Widget test extensions.
extension UbuntuWidgetTester on WidgetTester {
  /// Taps a _Back_ button.
  Future<void> tapBack() => _tapUbuntuButton((l10n) => l10n.backLabel);

  /// Taps a _Cancel_ button.
  Future<void> tapCancel() => _tapUbuntuButton((l10n) => l10n.cancelLabel);

  /// Taps a _Close_ button.
  Future<void> tapClose() => _tapUbuntuButton((l10n) => l10n.closeLabel);

  /// Taps a _Continue_ button.
  Future<void> tapContinue() => _tapUbuntuButton((l10n) => l10n.continueLabel);

  /// Taps a _Next_ button.
  Future<void> tapNext() => _tapUbuntuButton((l10n) => l10n.nextLabel);

  /// Taps an _Ok_ button.
  Future<void> tapOk() => _tapUbuntuButton((l10n) => l10n.okLabel);

  /// Taps a _Previous_ button.
  Future<void> tapPrevious() => _tapUbuntuButton((l10n) => l10n.previousLabel);

  Future<void> _tapUbuntuButton(UbuntuLocalizationFunction tr) {
    return tapButton(find.ul10n(tr));
  }
}
