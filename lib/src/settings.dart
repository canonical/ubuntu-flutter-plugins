import 'dart:async';

import 'package:flutter/widgets.dart';

class WizardRouteSettings<T extends Object?> extends RouteSettings {
  WizardRouteSettings({
    String? name,
    Object? arguments,
  }) : super(name: name, arguments: arguments);

  final result = Completer<T?>();
}
