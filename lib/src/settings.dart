import 'dart:async';

import 'package:flutter/widgets.dart';

class WizardRouteSettings<T extends Object?> extends RouteSettings {
  WizardRouteSettings({
    super.name,
    super.arguments,
  });

  final result = Completer<T?>();
}
