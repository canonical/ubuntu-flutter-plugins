import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wizard_router/wizard_router.dart';

import 'package:wizard_router_example/actions.dart';
import 'package:wizard_router_example/models.dart';
import 'package:wizard_router_example/pages.dart';
import 'package:wizard_router_example/routes.dart';
import 'package:wizard_router_example/services.dart';

void main() {
  final service = NetworkService();
  runApp(
    ChangeNotifierProvider(
      create: (_) => NetworkModel(service),
      child: const WizardApp(),
    ),
  );
}

class WizardApp extends StatelessWidget {
  const WizardApp({super.key});

  /// Optional to show use of Actions + controller in example
  /// Off by default to not affect tests.
  static bool useActions = false;

  @override
  Widget build(BuildContext context) {
    final controller = WizardController(
      initialRoute: Routes.initial,
      routes: <String, WizardRoute>{
        Routes.welcome: const WizardRoute(
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
        Routes.preview: const WizardRoute(
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
    );
    return MaterialApp(
      home: Actions(
        actions: wizardActions(controller: controller),
        child: Wizard(
          controller: controller,
        ),
      ),
    );
  }
}
