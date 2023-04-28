part of 'wizard.dart';

/// Allows widgets such as the AppBar to invoke functionality on the Wizard
/// This is useful for widgets that are defined above the Wizard, such as a mobile
/// app's AppBar.
class WizardController extends ChangeNotifier {
  WizardController({required this.routes, this.initialRoute}) {
    _flowController = FlowController(
        [WizardRouteSettings(name: initialRoute ?? routes.keys.first)]);
    _flowController.addListener(notifyListeners);
  }
  final String? initialRoute;
  final Map<String, WizardRoute> routes;
  late final FlowController<List<WizardRouteSettings>> _flowController;

  List<WizardRouteSettings> get state => _flowController.state;
  String get currentRoute => state.last.name!;

  void _updateState(
    List<WizardRouteSettings> Function(List<WizardRouteSettings>) callback,
  ) {
    _flowController.update(callback);
  }

  @override
  void dispose() {
    _flowController.removeListener(notifyListeners);
    _flowController.dispose();
    super.dispose();
  }

  /// Requests the wizard to show the first page.
  void home() {
    assert(state.length > 1,
        '`Wizard.home()` called from the first route ${state.last.name}');

    _updateState((state) {
      final copy = List<WizardRouteSettings>.of(state);
      return copy..replaceRange(1, state.length, []);
    });
  }

  /// Requests the wizard to show the previous page. Optionally, `result` can be
  /// returned to the previous page.
  void back<T extends Object?>([T? result]) {
    assert(state.length > 1,
        '`Wizard.back()` called from the first route ${state.last.name}');

    // go back to a specific route, or pick the previous route on the list
    final previous = routes[currentRoute]!.onBack?.call(state.last);
    if (previous != null) {
      assert(routes.keys.contains(previous),
          '`Wizard.routes` is missing route \'$previous\'.');
    }

    final start = previous != null
        ? state.lastIndexWhere((settings) => settings.name == previous) + 1
        : state.length - 1;

    _updateState((state) {
      final copy = List<WizardRouteSettings>.of(state);
      copy[start].completer.complete(result);
      return copy..replaceRange(start, state.length, []);
    });
  }

  /// Requests the wizard to show the next page. Optionally, `arguments` can be
  /// passed to the next page.
  Future<T?> next<T extends Object?>({T? arguments}) {
    final next = _getNextRoute<T>(arguments, routes[currentRoute]!.onNext);

    _updateState((state) {
      final copy = List<WizardRouteSettings>.of(state);
      return copy..add(next);
    });

    return next.completer.future;
  }

  WizardRouteSettings<T?> _getNextRoute<T extends Object?>(
    T? arguments,
    WizardRouteCallback? advance,
  ) {
    assert(state.isNotEmpty, state.length.toString());

    final previous = WizardRouteSettings(
      name: state.last.name,
      arguments: arguments,
    );

    // advance to a specific route
    String? onNext() => advance?.call(previous);

    // pick the next route on the list
    String nextRoute() {
      final routeNames = routes.keys.toList();
      final index = routeNames.indexOf(previous.name!);
      assert(index < routeNames.length - 1,
          '`Wizard.next()` called from the last route ${previous.name}.');
      return routeNames[index + 1];
    }

    final name = onNext() ?? nextRoute();
    assert(routes.keys.contains(name),
        '`Wizard.routes` is missing route \'$name\'.');

    return WizardRouteSettings<T?>(name: name, arguments: arguments);
  }

  /// Requests the wizard to replace the current page with the next one.
  /// Optionally, `arguments` can be passed to the next page.
  void replace({Object? arguments}) async {
    final next = _getNextRoute(arguments, routes[currentRoute]!.onReplace);

    _updateState((state) {
      final copy = List<WizardRouteSettings>.of(state);
      copy[copy.length - 1] = next;
      return copy;
    });
  }

  /// Requests the wizard to jump to a specific page. Optionally, `arguments`
  /// can be passed to the page.
  void jump(String route, {Object? arguments}) async {
    assert(routes.keys.contains(route),
        '`Wizard.jump()` called with an unknown route $route.');
    final settings = WizardRouteSettings(name: route, arguments: arguments);

    _updateState((state) {
      final copy = List<WizardRouteSettings>.of(state);
      return copy..add(settings);
    });
  }
}
