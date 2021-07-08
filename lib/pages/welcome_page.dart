import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services.dart';
import '../widgets.dart';
import '../wizard.dart';

class FirstModel extends ChangeNotifier {
  FirstModel(this._service);

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

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) {
    final service = Provider.of<NetworkService>(context, listen: false);
    return ChangeNotifierProvider(
      create: (_) => FirstModel(service),
      child: const FirstPage(),
    );
  }

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<FirstModel>(context, listen: false).init();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<FirstModel>(context);
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
