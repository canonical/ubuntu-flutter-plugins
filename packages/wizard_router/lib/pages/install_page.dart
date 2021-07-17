import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets.dart';
import '../wizard.dart';

class InstallModel extends ValueNotifier<int> {
  InstallModel() : super(0) {
    _timer = Timer.periodic(const Duration(milliseconds: 32), (timer) {
      ++value;
      if (value == 100) timer.cancel();
    });
  }

  int get progress => value;
  bool get isInstalling => _timer.isActive;

  late final Timer _timer;

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}

class InstallPage extends StatelessWidget {
  const InstallPage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InstallModel(),
      child: const InstallPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<InstallModel>(context);
    return WizardPage(
      title: const Text('Install'),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(model.progress == 100 ? 'Done!' : 'Installing...'),
            const SizedBox(height: 24),
            LinearProgressIndicator(value: model.progress / 100.0),
          ],
        ),
      ),
      actions: [
        WizardAction(
          label: 'Back',
          onActivated: model.progress < 100 ? Wizard.of(context).back : null,
        ),
        WizardAction(
          label: 'Finish',
          onActivated: model.progress == 100 ? Wizard.of(context).next : null,
        ),
      ],
    );
  }
}
