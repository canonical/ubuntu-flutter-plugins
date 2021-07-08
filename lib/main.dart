import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
import 'services.dart';
import 'wizard.dart';

void main() {
  runApp(
    Provider.value(
      value: NetworkService(),
      child: const WizardApp(),
    ),
  );
}

class WizardApp extends StatelessWidget {
  const WizardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Wizard(
        initialRoute: Routes.initialPage,
        nextRoute: Routes.nextPage,
        pageBuilder: Routes.createPage,
      ),
    );
  }
}
