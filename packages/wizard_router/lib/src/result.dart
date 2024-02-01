import 'package:flutter/widgets.dart';

import 'package:wizard_router/src/settings.dart';

class WizardRouteResult<T extends Object?> extends WizardRouteSettings<T> {
  WizardRouteResult(
    WizardRouteSettings<T> settings, {
    required this.route,
    required this.result,
  }) : super(name: settings.name, arguments: settings.arguments);

  final Route<void> route;
  final Object? result;

  @override
  // ignore: no_runtimetype_tostring
  String toString() => '$runtimeType("$name", $arguments, $result)';
}
