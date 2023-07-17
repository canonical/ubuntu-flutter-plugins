part of 'wizard.dart';

/// Allows widgets such as the AppBar to invoke functionality on the Wizard
/// This is useful for widgets that are defined above the Wizard, such as a mobile
/// app's AppBar.
class WizardController extends SafeChangeNotifier {
  WizardController({required this.routes, this.initialRoute}) {
    _flowController = FlowController(
        [WizardRouteSettings(name: initialRoute ?? routes.keys.first)]);
    _flowController.addListener(notifyListeners);
  }
  final String? initialRoute;
  final Map<String, WizardRoute> routes;
  late final FlowController<List<WizardRouteSettings>> _flowController;

  int _loading = 0;
  bool get isLoading => _loading > 0;
  Future<WizardRouteSettings<T>> _loadRoute<T>(
    String name,
    Future<WizardRouteSettings<T>> Function(String name) getRoute,
  ) async {
    if (++_loading == 1) notifyListeners();
    try {
      var next = await getRoute(name);
      while (await routes[next.name]!.onLoad?.call(next) == false) {
        next = await getRoute(next.name!);
      }
      return next;
    } finally {
      if (--_loading == 0) notifyListeners();
    }
  }

  List<WizardRouteSettings> get state => _flowController.state;
  String get currentRoute => state.last.name!;

  void _updateState(
    List<WizardRouteSettings> Function(List<WizardRouteSettings>) callback,
  ) {
    if (!isDisposed) _flowController.update(callback);
  }

  @override
  void dispose() {
    _flowController.removeListener(notifyListeners);
    _flowController.dispose();
    super.dispose();
  }

  /// Requests the wizard to show the first page.
  void home() {
    if (state.length <= 1) {
      throw WizardException(
          '`Wizard.home()` called from the first route ${state.last.name}');
    }

    _updateState((state) {
      final copy = List<WizardRouteSettings>.of(state);
      return copy..replaceRange(1, state.length, []);
    });
  }

  /// Requests the wizard to show the previous page. Optionally, `result` can be
  /// returned to the previous page.
  void back<T extends Object?>([T? result]) async {
    if (state.length <= 1) {
      throw WizardException(
          '`Wizard.back()` called from the first route ${state.last.name}');
    }

    // go back to a specific route, or pick the previous route on the list
    final previous = await routes[currentRoute]!.onBack?.call(state.last);
    if (previous != null) {
      if (!routes.keys.contains(previous)) {
        throw WizardException(
            '`Wizard.routes` is missing route \'$previous\'.');
      }
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
  Future<T?> next<T extends Object?>({Object? arguments}) async {
    final next = await _loadRoute<T>(currentRoute, (name) {
      return _getNextRoute<T>(name, arguments, routes[name]!.onNext);
    });

    _updateState((state) {
      final copy = List<WizardRouteSettings>.of(state);
      return copy..add(next);
    });

    return next.completer.future;
  }

  Future<WizardRouteSettings<T>> _getNextRoute<T extends Object?>(
    String from,
    Object? arguments,
    WizardRouteCallback? advance,
  ) async {
    assert(state.isNotEmpty, state.length.toString());

    final previous = WizardRouteSettings(
      name: from,
      arguments: arguments,
    );

    // advance to a specific route
    FutureOr<String?> onNext() => advance?.call(previous);

    // pick the next route on the list
    String nextRoute() {
      final routeNames = routes.keys.toList();
      final index = routeNames.indexOf(previous.name!);
      if (index == routeNames.length - 1) {
        throw WizardException(
            '`Wizard.next()` called from the last route ${previous.name}.');
      }
      return routeNames[index + 1];
    }

    final name = await onNext() ?? nextRoute();
    if (!routes.keys.contains(name)) {
      throw WizardException('`Wizard.routes` is missing route \'$name\'.');
    }

    return WizardRouteSettings<T>(name: name, arguments: arguments);
  }

  /// Requests the wizard to replace the current page with the next one.
  /// Optionally, `arguments` can be passed to the next page.
  Future<T?> replace<T extends Object?>({Object? arguments}) async {
    final next = await _loadRoute<T>(currentRoute, (name) {
      return _getNextRoute<T>(name, arguments, routes[name]!.onReplace);
    });

    _updateState((state) {
      final copy = List<WizardRouteSettings>.of(state);
      copy[copy.length - 1] = next;
      return copy;
    });
    return next.completer.future;
  }

  /// Requests the wizard to jump to a specific page. Optionally, `arguments`
  /// can be passed to the page.
  Future<T?> jump<T extends Object?>(String route, {Object? arguments}) async {
    if (!routes.keys.contains(route)) {
      throw WizardException(
          '`Wizard.jump()` called with an unknown route $route.');
    }
    final settings = await _loadRoute(route, (name) async {
      return WizardRouteSettings<T>(name: name, arguments: arguments);
    });

    _updateState((state) {
      final copy = List<WizardRouteSettings>.of(state);
      return copy..add(settings);
    });
    return settings.completer.future;
  }
}
