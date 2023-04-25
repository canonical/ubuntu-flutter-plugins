import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wizard_router/wizard_router.dart';

import '../widgets.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({super.key});

  static Widget create(BuildContext context) => const PreviewPage();

  @override
  Widget build(BuildContext context) {
    return WizardPage(
      title: const Text('Preview'),
      body: const Center(
        child: Text('This is the end of the preview route.'),
      ),
      actions: [
        WizardAction(
          label: 'Back',
          onActivated: Wizard.of(context).back,
        ),
        WizardAction(
          label: 'Finish',
          onActivated: () => exit(0),
        ),
      ],
    );
  }
}
