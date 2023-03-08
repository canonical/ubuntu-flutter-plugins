// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:wizard_router/wizard_router.dart';
import 'package:wizard_router_example/actions.dart';

import 'models.dart';
import 'pages.dart';
import 'routes.dart';
import 'services.dart';

void main() {
  final service = NetworkService();
  runApp(
    ChangeNotifierProvider(
      create: (_) => NetworkModel(service),
      child: WizardApp(),
    ),
  );
}

class WizardApp extends StatelessWidget {
  WizardApp({Key? key}) : super(key: key);

  /// Optional to show use of Actions + controller in example
  /// Off by default to not affect tests.
  static bool useActions = false;

  final WizardController controller = WizardController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Actions(
        actions: wizardActions(controller: controller),
        child: Wizard(
          controller: controller,
          initialRoute: Routes.initial,
          routes: <String, WizardRoute>{
            Routes.welcome: WizardRoute(
              builder: WelcomePage.create,
            ),
            Routes.chooser: WizardRoute(
              builder: ChooserPage.create,
              onNext: (settings) {
                switch (settings.arguments as Choice?) {
                  case Choice.preview:
                    return Routes.preview;
                  case Choice.install:
                    if (!context.read<NetworkModel>().isConnected) {
                      return Routes.connect;
                    }
                    return Routes.install;
                  default:
                    throw ArgumentError(settings.arguments);
                }
              },
            ),
            Routes.preview: WizardRoute(
              builder: PreviewPage.create,
            ),
            Routes.connect: WizardRoute(
              builder: ConnectPage.create,
              onBack: (_) => Routes.chooser,
            ),
            Routes.install: WizardRoute(
              builder: InstallPage.create,
              onBack: (_) => Routes.chooser,
            ),
          },
        ),
      ),
    );
  }
}
