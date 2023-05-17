import 'package:flutter_test/flutter_test.dart';
import 'package:yaru_test/yaru_test.dart';

import 'common_finders.dart';

/// Widget test extensions.
extension UbuntuWidgetTester on WidgetTester {
  /// Taps a _Back_ button.
  Future<void> tapBack() => tapButton(find.backLabel);

  /// Taps a _Cancel_ button.
  Future<void> tapCancel() => tapButton(find.cancelLabel);

  /// Taps a _Close_ button.
  Future<void> tapClose() => tapButton(find.closeLabel);

  /// Taps a _Continue_ button.
  Future<void> tapContinue() => tapButton(find.continueLabel);

  /// Taps a _Next_ button.
  Future<void> tapNext() => tapButton(find.nextLabel);

  /// Taps an _Ok_ button.
  Future<void> tapOk() => tapButton(find.okLabel);

  /// Taps a _Previous_ button.
  Future<void> tapPrevious() => tapButton(find.previousLabel);
}
