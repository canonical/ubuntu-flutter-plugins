import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services.dart';
import '../widgets.dart';
import '../wizard.dart';

class WelcomeModel extends ChangeNotifier {
  WelcomeModel(this._service);

  final NetworkService _service;

  void init() {
    _service.isConnected().then((value) => _updateConnected(value));
  }

  bool _connected = false;
  bool get isConnected => _connected;
  void setConnected(bool value) {
    _service.setConnectedForTesting(value);
    _updateConnected(value);
  }

  void _updateConnected(bool value) {
    if (_connected == value) return;
    _connected = value;
    notifyListeners();
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) {
    final service = Provider.of<NetworkService>(context, listen: false);
    return ChangeNotifierProvider(
      create: (_) => WelcomeModel(service),
      child: const WelcomePage(),
    );
  }

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<WelcomeModel>(context, listen: false).init();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<WelcomeModel>(context);
    final description =
        model.isConnected ? 'Skip connect page' : 'Don\'t skip connect page';
    return WizardPage(
      name: 'Welcome (1/3)',
      leading: WizardCheckbox(
        value: model.isConnected,
        title: Text('Connected ($description)'),
        onChanged: (value) => model.setConnected(value!),
      ),
      onNext: () => Wizard.of(context).next(),
    );
  }
}
