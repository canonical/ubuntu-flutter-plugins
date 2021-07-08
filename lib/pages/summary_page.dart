import 'package:flutter/material.dart';

import '../widgets.dart';
import '../wizard.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) => const SummaryPage();

  @override
  Widget build(BuildContext context) {
    return WizardPage(
      name: 'Summary (3/3)',
      onBack: () => Wizard.of(context).back(),
    );
  }
}
