import 'package:flutter/material.dart';

import '../widgets.dart';
import '../wizard.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) => const SecondPage();

  @override
  Widget build(BuildContext context) {
    return WizardPage(
      name: 'Connect (2/3)',
      onBack: () => Wizard.of(context).back(),
      onNext: () => Wizard.of(context).next(),
    );
  }
}
