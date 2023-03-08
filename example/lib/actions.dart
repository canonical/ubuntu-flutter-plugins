import 'package:flutter/material.dart';
import 'package:wizard_router/wizard_router.dart';

class WizardNextIntent extends Intent {
  final Object? arguments;

  WizardNextIntent({this.arguments});

  static void invoke({required BuildContext context, Object? arguments}) {
    Actions.invoke(
      context,
      WizardNextIntent(arguments: arguments),
    );
  }
}

class WizardBackIntent extends Intent {
  final Object? arguments;
  WizardBackIntent({
    this.arguments,
  });

  static void invoke({required BuildContext context, Object? arguments}) {
    Actions.invoke(
      context,
      WizardBackIntent(arguments: arguments),
    );
  }
}

wizardActions({required WizardController controller}) => {
      WizardNextIntent: CallbackAction<WizardNextIntent>(
        onInvoke: (intent) => controller.next(arguments: intent.arguments),
      ),
      WizardBackIntent: CallbackAction<WizardBackIntent>(
        onInvoke: (intent) => controller.back(arguments: intent.arguments),
      )
    };
