import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wizard_router/wizard_router.dart';

import 'models.dart';
import 'pages.dart';
import 'routes.dart';
import 'services.dart';

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
  const WizardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Wizard(
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
    );
  }
}
