import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wizard_router/wizard_router.dart';
import 'package:wizard_router_example/actions.dart';
import 'package:wizard_router_example/main.dart';

import '../models.dart';
import '../widgets.dart';

enum Choice { none, preview, install }

class ChooserModel extends ValueNotifier<Choice> {
  ChooserModel(Choice choice) : super(choice);
}

class ChooserPage extends StatelessWidget {
  const ChooserPage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChooserModel(Choice.none),
      child: const ChooserPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<ChooserModel>(context);
    final network = Provider.of<NetworkModel>(context);
    return WizardPage(
      title: const Text('Choice'),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'On this page, the user is presented with a choice that '
              'determines the next page.',
            ),
            const SizedBox(height: 24),
            ToggleButtons(
              isSelected: <bool>[
                model.value == Choice.preview,
                model.value == Choice.install,
              ],
              onPressed: (index) => model.value = Choice.values[index + 1],
              children: const <Widget>[
                Padding(padding: EdgeInsets.all(16.0), child: Text('Preview')),
                Padding(padding: EdgeInsets.all(16.0), child: Text('Install')),
              ],
            ),
            const SizedBox(height: 48),
            const Text(
              'For testing purposes, this checkbox determines whether the '
              'system is online.\nIf not, the wizard continues with a page to '
              'establish a network connection.\nOtherwise, the wizard will '
              'proceed straight to the final installation page.',
            ),
            WizardCheckbox(
              value: network.isConnected,
              title: const Text('Online'),
              onChanged: (value) => network.setConnected(value!),
            ),
          ],
        ),
      ),
      actions: [
        WizardAction(
          label: 'Back',
          onActivated: () => WizardApp.useActions
              ? WizardBackIntent.invoke(context: context)
              : Wizard.of(context).back(),
        ),
        WizardAction(
          label: 'Next',
          onActivated: model.value != Choice.none
              ? () => WizardApp.useActions
                  ? WizardNextIntent.invoke(
                      context: context, arguments: model.value)
                  : Wizard.of(context).next(arguments: model.value)
              : null,
        ),
      ],
    );
  }
}
