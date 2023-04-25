import 'package:flutter/widgets.dart';
import 'package:wizard_router/wizard_router.dart';

class WizardNextIntent extends Intent {
  const WizardNextIntent({this.arguments});

  final Object? arguments;

  static void invoke({required BuildContext context, Object? arguments}) {
    Actions.invoke(
      context,
      WizardNextIntent(arguments: arguments),
    );
  }
}

class WizardBackIntent extends Intent {
  const WizardBackIntent({this.arguments});

  final Object? arguments;

  static void invoke({required BuildContext context, Object? arguments}) {
    Actions.invoke(
      context,
      WizardBackIntent(arguments: arguments),
    );
  }
}

Map<Type, Action<Intent>> wizardActions(
        {required WizardController controller}) =>
    {
      WizardNextIntent: CallbackAction<WizardNextIntent>(
        onInvoke: (intent) => controller.next(arguments: intent.arguments),
      ),
      WizardBackIntent: CallbackAction<WizardBackIntent>(
        onInvoke: (intent) => controller.back(arguments: intent.arguments),
      )
    };
