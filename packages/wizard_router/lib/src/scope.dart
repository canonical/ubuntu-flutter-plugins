import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:wizard_router/src/route.dart';
import 'package:wizard_router/src/wizard.dart';

/// The scope of a wizard page.
///
/// Each page is enclosed by a `WizardScope` widget.
class WizardScope extends StatefulWidget {
  const WizardScope({
    required int index,
    required WizardController controller,
    required WizardRoute route,
    Object? userData,
    super.key,
  })  : _index = index,
        _userData = userData,
        _route = route,
        _controller = controller;

  final int _index;
  final Object? _userData;
  final WizardController _controller;
  final WizardRoute _route;

  @override
  State<WizardScope> createState() => WizardScopeState();
}

/// The state of a `WizardScope`, accessed via `Wizard.of(context)`.
class WizardScopeState extends State<WizardScope> {
  /// Arguments passed from the previous page.
  ///
  /// ```dart
  /// final something = Wizard.of(context).arguments as Something;
  /// ```
  Object? get arguments => ModalRoute.of(context)?.settings.arguments;

  /// Requests the wizard to show the first page.
  ///
  /// ```dart
  /// onPressed: Wizard.of(context).home
  /// ```
  void home() => widget._controller.home();

  /// Requests the wizard to show the previous page. Optionally, `result` can be
  /// returned to the previous page.
  ///
  /// ```dart
  /// onPressed: Wizard.of(context).back
  /// ```
  void back<T extends Object?>([T? result]) => widget._controller.back(result);

  /// Requests the wizard to show the previous page. Optionally, `result` can be
  /// returned to the previous page.
  /// Compared to `back`, `previous` refers to the route settings to load the
  /// previous page instead of the navigation history.
  ///
  /// ```dart
  /// onPressed: Wizard.of(context).previous
  /// ```
  void previous<T extends Object?>([T? result]) =>
      widget._controller.previous(result);

  /// Requests the wizard to show the next page. Optionally, `arguments` can be
  /// passed to the next page.
  ///
  /// ```dart
  /// onPressed: Wizard.of(context).next
  /// ```
  Future<T?> next<T extends Object?>({Object? arguments}) =>
      widget._controller.next(arguments: arguments);

  /// Requests the wizard to replace the current page with the next one.
  /// Optionally, `arguments` can be passed to the next page.
  ///
  /// ```dart
  /// onPressed: () => Wizard.of(context).replace(arguments: something),
  /// ```
  Future<T?> replace<T extends Object?>({Object? arguments}) =>
      widget._controller.replace(arguments: arguments);

  /// Requests the wizard to jump to a specific page. Optionally, `arguments`
  /// can be passed to the page.
  Future<T?> jump<T extends Object?>(String route, {Object? arguments}) =>
      widget._controller.jump(route, arguments: arguments);

  /// Requests the wizard to jump to the error page, if available.
  Future<T?> showError<T extends Object?>(Object error) =>
      widget._controller.showError(error);

  /// Returns `false` if the wizard page is the first page.
  bool get hasPrevious => widget._index > 0;

  /// Returns `false` if the wizard page is the last page.
  bool get hasNext {
    final routes = widget._controller.routes;
    if (routes.isEmpty) return false;
    final previous = widget._controller.currentRoute;
    final previousIndex = routes.keys.toList().indexOf(previous);
    return previousIndex < routes.length - 1;
  }

  WizardController get controller => widget._controller;

  /// Returns `true` if the wizard is awaiting an `onLoad` callback.
  bool get isLoading => widget._controller.isLoading;

  Object? get routeData => widget._route.userData;
  Object? get wizardData => widget._userData;

  @override
  Widget build(BuildContext context) => Builder(builder: widget._route.builder);
}
