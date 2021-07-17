import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages.dart';
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
        initialRoute: Routes.initial,
        nextRoute: Routes.nextRoute,
        routes: {
          Routes.welcome: WelcomePage.create,
          Routes.connect: ConnectPage.create,
          Routes.summary: SummaryPage.create,
        },
      ),
    );
  }
}
