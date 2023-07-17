import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wizard_router/wizard_router.dart';

import '../models.dart';
import '../widgets.dart';

class ConnectPage extends StatelessWidget {
  const ConnectPage({super.key});

  static Widget create(BuildContext context) => const ConnectPage();

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<NetworkModel>(context);
    return WizardPage(
      title: const Text('Connect'),
      body: Center(
        child: model.isConnected
            ? const Text('Connected!')
            : ElevatedButton(
                onPressed: () => model.setConnected(true),
                child: const Text('Connect'),
              ),
      ),
      actions: [
        WizardAction(
          label: 'Back',
          onActivated: Wizard.of(context).back,
        ),
        WizardAction(
          label: 'Next',
          onActivated: model.isConnected ? Wizard.of(context).next : null,
        ),
      ],
    );
  }
}
