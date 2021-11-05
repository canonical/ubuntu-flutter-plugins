import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flow_builder/flow_builder.dart';

/// The signature of [WizardRoute.onNext] and [WizardRoute.onBack] callbacks.
typedef WizardRouteCallback = String? Function(RouteSettings settings);

class WizardRoute {
  const WizardRoute({
    required this.builder,
    this.onNext,
    this.onBack,
  });

  final WidgetBuilder builder;

  /// The callback invoked when the next page is requested.
  ///
  /// If `onNext` is not specified or it returns `null`, the order is determined
  /// from [routes].
  final WizardRouteCallback? onNext;

  /// The callback invoked when the previous page is requested.
  ///
  /// If `onBack` is not specified or it returns `null`, the order is determined
  /// from [routes].
  final WizardRouteCallback? onBack;
}

/// A wizard is a flow of steps that the user can navigate through.
///
/// `Wizard` provides routing for classic linear wizards in a way that it
/// eliminates dependencies between wizard pages. Wizard pages can request the
/// next or previous page without knowing or caring what is the next or the
/// previous wizard page. Thus, adding, removing, or re-ordering pages does not
/// cause changes in existing pages.
///
/// ![wizard_router](https://github.com/jpnurmi/wizard_router/raw/main/images/wizard_router.png)
///
/// ## Usage
///
/// ### Routes
///
/// ```dart
/// MaterialApp(
///   home: Scaffold(
///     body: Wizard(
///       routes: {
///         '/foo': WizardRoute(builder: (context) => FooPage()),
///         '/bar': WizardRoute(builder: (context) => BarPage()),
///         '/baz': WizardRoute(builder: (context) => BazPage()),
///       },
///     ),
///   ),
/// )
/// ```
///
/// ### Navigation
///
/// The next or the previous page is requested by calling `Wizard.of(context).next()`
/// or `Wizard.of(context).back()`, respectively.
///
/// ```dart
/// BarPage(
///   child: ButtonBar(
///     children: [
///       ElevatedButton(
///         onPressed: Wizard.of(context).back
///         child: const Text('Back'),
///       ),
///       ElevatedButton(
///         onPressed: Wizard.of(context).next
///         child: const Text('Next'),
///       ),
///     ],
///   ),
/// )
/// ```
///
/// ### Conditions
///
/// For unconditional linear wizards, defining the routes is enough. The router
/// follows the order the routes are defined in. If there are conditions between
/// the wizard pages, the order can be customized with the `WizardRoute.onNext`
/// and `WizardRoute.onBack` callbacks.
///
/// ```dart
/// Wizard(
///   routes: {
///     '/foo': WizardRoute(
///       builder: (context) => FooPage(),
///       // conditionally skip the _Bar_ page when stepping forward from the _Foo_ page
///       onNext: (settings) => skipBar ? '/baz' : null,
///     ),
///     '/bar': WizardRoute(builder: (context) => BarPage()),
///     '/baz': WizardRoute(builder: (context) => BazPage()),
///     '/qux': WizardRoute(
///       builder: (context) => QuxPage(),
///       // always skip the Baz page when stepping back from the Qux page
///       onBack: (settings) => '/bar',
///     ),
///   },
/// )
/// ```
///
/// ### Arguments
///
/// It is recommended to avoid such dependencies between wizard pages that make
/// assumptions of the page order. However, sometimes it may be desirable to pass
/// arguments to the next page. This is possible by passing them to
/// `Wizard.of(context).next(arguments)`. On the next page, the arguments can be
/// queried from `Wizard.of(context).arguments`.
///
/// ```dart
/// FooPage(
///   onFoo: () => Wizard.of(context).next(arguments: something),
/// )
///
/// BarPageState extends State<BarPage>(
///   @override
///   void initState() {
///     super.initState();
///
///     final something = Wizard.of(context).arguments as Something;
///     // ...
///   }
/// )
/// ```
class Wizard extends StatefulWidget {
  /// Creates an instance of a wizard. The `routes` argument is required.
  const Wizard({
    Key? key,
    this.initialRoute,
    required this.routes,
  }) : super(key: key);

  /// The name of the first route to show.
  ///
  /// If `initialRoute` not specified, the first route from [routes] is
  /// considered the initial route.
  final String? initialRoute;

  /// The wizards's routing table.
  ///
  /// The order of `routes` is the order of the wizard pages are shown. The
  /// order can be customized with [WizardRoute.onNext] and [WizardRoute.onBack].
  final Map<String, WizardRoute> routes;

  /// The wizard scope from the closest instance of this class that encloses the
  /// given `context`.
  ///
  /// See also:
  /// - [WizardScopeState.next]
  /// - [WizardScopeState.arguments]
  /// - [WizardScopeState.back]
  /// - [WizardScopeState.home]
  static WizardScopeState of(BuildContext context) {
    final scope = context.findAncestorStateOfType<WizardScopeState>();
    assert(() {
      if (scope == null) {
        throw FlutterError(
          'Wizard operation requested with a context that does not include a Wizard.\n'
          'The context passed to Wizard.of(context) must belong to a widget that is a descendant of a Wizard widget.',
        );
      }
      return true;
    }());
    return scope!;
  }

  @override
  State<Wizard> createState() => _WizardState();
}

class _WizardState extends State<Wizard> {
  late List<_WizardRouteSettings> _routes;

  @override
  void initState() {
    super.initState();
    _routes = <_WizardRouteSettings>[
      _WizardRouteSettings(
          name: widget.initialRoute ?? widget.routes.keys.first),
    ];
  }

  Page _createPage(BuildContext context,
      {required _WizardRouteSettings settings}) {
    return MaterialPage(
      name: settings.name,
      arguments: settings.arguments,
      key: ValueKey(settings.name),
      child: WizardScope(
        route: widget.routes[settings.name]!,
        routes: widget.routes.keys.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<List<_WizardRouteSettings>>(
      state: _routes,
      onGeneratePages: (state, __) {
        _routes = state;
        return state
            .map((settings) => _createPage(context, settings: settings))
            .toList();
      },
    );
  }
}

/// The scope of a wizard page.
///
/// Each page is enclosed by a `WizardScope` widget.
class WizardScope extends StatefulWidget {
  const WizardScope({
    Key? key,
    required WizardRoute route,
    required List<String> routes,
  })  : _route = route,
        _routes = routes,
        super(key: key);

  final WizardRoute _route;
  final List<String> _routes;

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
  void home() {
    final routes = _getRoutes();
    assert(routes.length > 1,
        '`Wizard.home()` called from the first route ${routes.last.name}');

    _updateRoutes((state) {
      final copy = List<_WizardRouteSettings>.of(state);
      return copy..replaceRange(1, routes.length, []);
    });
  }

  /// Requests the wizard to show the previous page. Optionally, `result` can be
  /// returned to the previous page.
  ///
  /// ```dart
  /// onPressed: Wizard.of(context).back
  /// ```
  void back<T extends Object?>([T? result]) {
    final routes = _getRoutes();
    assert(routes.length > 1,
        '`Wizard.back()` called from the first route ${routes.last.name}');

    // go back to a specific route, or pick the previous route on the list
    final previous = widget._route.onBack?.call(routes.last);
    if (previous != null) {
      assert(widget._routes.contains(previous),
          '`Wizard.routes` is missing route \'$previous\'.');
    }

    final start = previous != null
        ? routes.lastIndexWhere((settings) => settings.name == previous) + 1
        : routes.length - 1;

    _updateRoutes((state) {
      final copy = List<_WizardRouteSettings>.of(state);
      copy[start].result.complete(result);
      return copy..replaceRange(start, routes.length, []);
    });
  }

  /// Requests the wizard to show the next page. Optionally, `arguments` can be
  /// passed to the next page.
  ///
  /// ```dart
  /// onPressed: Wizard.of(context).next
  /// ```
  Future<T?> next<T extends Object?>({Object? arguments}) {
    final routes = _getRoutes();
    assert(routes.isNotEmpty, routes.length.toString());

    final previous = routes.last.copyWith(arguments: arguments);

    // advance to a specific route
    String? onNext() => widget._route.onNext?.call(previous);

    // pick the next route on the list
    String nextRoute() {
      final index = widget._routes.indexOf(previous.name!);
      assert(index < widget._routes.length - 1,
          '`Wizard.next()` called from the last route ${previous.name}.');
      return widget._routes[index + 1];
    }

    final next = _WizardRouteSettings<T?>(
      name: onNext() ?? nextRoute(),
      arguments: arguments,
    );

    assert(widget._routes.contains(next.name),
        '`Wizard.routes` is missing route \'${next.name}\'.');

    _updateRoutes((state) {
      final copy = List<_WizardRouteSettings>.of(state);
      return copy..add(next);
    });

    return next.result.future;
  }

  List<_WizardRouteSettings> _getRoutes() =>
      context.flow<List<_WizardRouteSettings>>().state;

  void _updateRoutes(
    List<_WizardRouteSettings> Function(List<_WizardRouteSettings>) callback,
  ) {
    context.flow<List<_WizardRouteSettings>>().update(callback);
  }

  /// Returns `false` if the wizard is currently on the first page.
  bool get hasPrevious => _getRoutes().length > 1;

  /// Returns `false` if the wizard is currently on the last page.
  bool get hasNext => _getRoutes().length < widget._routes.length;

  @override
  Widget build(BuildContext context) => Builder(builder: widget._route.builder);
}

class _WizardRouteSettings<T extends Object?> extends RouteSettings {
  _WizardRouteSettings({
    String? name,
    Object? arguments,
  }) : super(name: name, arguments: arguments);

  final result = Completer<T?>();
}
