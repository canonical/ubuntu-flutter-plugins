import 'package:flutter/material.dart';
import 'package:flutter_wizard/flutter_wizard.dart';
import 'package:provider/provider.dart';

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
        routes: const <String, WidgetBuilder>{
          Routes.welcome: WelcomePage.create,
          Routes.chooser: ChooserPage.create,
          Routes.preview: PreviewPage.create,
          Routes.connect: ConnectPage.create,
          Routes.install: InstallPage.create,
        },
        onNext: (settings) {
          switch (settings.name) {
            case Routes.chooser:
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
            default:
              return null;
          }
        },
        onBack: (settings) {
          switch (settings.name) {
            case Routes.connect:
              return Routes.chooser;
            case Routes.install:
              return Routes.chooser;
            default:
              return null;
          }
        },
      ),
    );
  }
}
