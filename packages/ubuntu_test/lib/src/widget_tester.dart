import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_test/src/common_finders.dart';
import 'package:yaru_test/yaru_test.dart';

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

  /// Taps a _Done_ button.
  Future<void> tapDone() => tapButton(find.doneLabel);

  /// Taps a link with the given [label].
  Future<void> tapLink(String label) async {
    expect(find.byWidgetPredicate((widget) {
      if (widget is RichText) {
        final link = widget.findLink(label);
        if (link != null) {
          (link.recognizer as TapGestureRecognizer).onTap!();
          return true;
        }
      }
      return false;
    }), findsOneWidget,);
  }

  /// Taps a _Next_ button.
  Future<void> tapNext() => tapButton(find.nextLabel);

  /// Taps a _No_ button.
  Future<void> tapNo() => tapButton(find.noLabel);

  /// Taps an _Ok_ button.
  Future<void> tapOk() => tapButton(find.okLabel);

  /// Taps a _Previous_ button.
  Future<void> tapPrevious() => tapButton(find.previousLabel);

  /// Taps a _Yes_ button.
  Future<void> tapYes() => tapButton(find.yesLabel);
}

extension on RichText {
  TextSpan? findLink(String label) {
    TextSpan? span;
    text.visitChildren((child) {
      if (child is TextSpan &&
          child.text == label &&
          child.recognizer is TapGestureRecognizer) {
        span = child;
      }
      return span == null;
    });
    return span;
  }
}
