import 'package:flutter/widgets.dart';

import 'settings.dart';

class WizardRouteResult<T extends Object?> extends WizardRouteSettings<T> {
  WizardRouteResult(
    WizardRouteSettings<T> settings, {
    required this.route,
    required this.result,
  }) : super(name: settings.name, arguments: settings.arguments);

  final Route route;
  final Object? result;

  @override
  String toString() => '$runtimeType("$name", $arguments, $result)';
}
