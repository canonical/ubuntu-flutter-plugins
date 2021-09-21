import 'package:flutter/material.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:provider/provider.dart';

/// The signature of [Wizard.onNext] and [Wizard.onBack] callbacks.
typedef WizardRouteCallback = String? Function(RouteSettings settings);

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
///         '/foo': (context) => FooPage(),
///         '/bar': (context) => BarPage(),
///         '/baz': (context) => BazPage(),
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
/// the wizard pages, the order can be customized with the `Wizard.onNext` and
/// `Wizard.onBack` callbacks.
///
/// ```dart
/// Wizard(
///   routes: {
///     '/foo': (context) => FooPage(),
///     '/bar': (context) => BarPage(),
///     '/baz': (context) => BazPage(),
///     '/qux': (context) => QuxPage(),
///   },
///   onNext: (settings) {
///     // conditionally skip the _Bar_ page when stepping forward from the _Foo_ page
///     if (settings.name == '/foo' && skipBar) return '/baz';
///     return null;
///   }
///   onBack: (settings) {
///     // always skip the Baz page when stepping back from the Qux page
///     if (settings.name == '/qux') return '/bar';
///     return null;
///   }
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
    this.onNext,
    this.onBack,
  }) : super(key: key);

  /// The name of the first route to show.
  ///
  /// If `initialRoute` not specified, the first route from [routes] is
  /// considered the initial route.
  final String? initialRoute;

  /// The wizards's routing table.
  ///
  /// The order of `routes` is the order of the wizard pages are shown. The
  /// order can be customized with [onNext] and [onBack].
  final Map<String, WidgetBuilder> routes;

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

  /// The wizard scope from the closest instance of this class that encloses the
  /// given `context`.
  ///
  /// See also:
  /// - [WizardScopeState.next]
  /// - [WizardScopeState.arguments]
  /// - [WizardScopeState.back]
  /// - [WizardScopeState.home]
  static WizardScopeState of(BuildContext context) {
    return Provider.of<WizardScopeState>(context, listen: false);
  }

  @override
  State<Wizard> createState() => _WizardState();
}

class _WizardState extends State<Wizard> {
  late List<RouteSettings> _routes;

  @override
  void initState() {
    super.initState();
    _routes = <RouteSettings>[
      RouteSettings(name: widget.initialRoute ?? widget.routes.keys.first),
    ];
  }

  Page _createPage(BuildContext context, {required RouteSettings settings}) {
    final route = settings.name;
    final builder = widget.routes[route];

    return MaterialPage(
      name: settings.name,
      arguments: settings.arguments,
      key: ValueKey(settings.name),
      child: WizardScope(
        routes: widget.routes.keys.toList(),
        onNext: widget.onNext,
        onBack: widget.onBack,
        child: builder!(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      child: FlowBuilder<List<RouteSettings>>(
        state: _routes,
        onGeneratePages: (state, __) {
          _routes = state;
          return state
              .map((settings) => _createPage(context, settings: settings))
              .toList();
        },
      ),
    );
  }
}

/// The scope of a wizard page.
///
/// Each page is enclosed by a `WizardScope` widget.
class WizardScope extends StatefulWidget {
  const WizardScope({
    Key? key,
    required Widget child,
    required List<String> routes,
    WizardRouteCallback? onNext,
    WizardRouteCallback? onBack,
  })  : _child = child,
        _routes = routes,
        _onNext = onNext,
        _onBack = onBack,
        super(key: key);

  final Widget _child;
  final List<String> _routes;
  final WizardRouteCallback? _onNext;
  final WizardRouteCallback? _onBack;

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
    final routes = context.flow<List<RouteSettings>>().state;
    assert(routes.length > 1,
        '`Wizard.back()` called from the first route ${routes.last.name}');

    context.flow<List<RouteSettings>>().update((state) {
      final copy = List<RouteSettings>.of(state);
      return copy..replaceRange(1, routes.length, []);
    });
  }

  /// Requests the wizard to show the previous page.
  ///
  /// ```dart
  /// onPressed: Wizard.of(context).back
  /// ```
  void back() {
    final routes = _getRoutes();
    assert(routes.length > 1,
        '`Wizard.back()` called from the first route ${routes.last.name}');

    // go back to a specific route, or pick the previous route on the list
    final previous = widget._onBack?.call(routes.last);
    if (previous != null) {
      assert(widget._routes.contains(previous),
          '`Wizard.routes` is missing route \'$previous\'.');
    }

    final start = previous != null
        ? routes.lastIndexWhere((settings) => settings.name == previous) + 1
        : routes.length - 1;

    context.flow<List<RouteSettings>>().update((state) {
      final copy = List<RouteSettings>.of(state);
      return copy..replaceRange(start, routes.length, []);
    });
  }

  /// Requests the wizard to show the next page. Optionally, `arguments` can be
  /// passed to the next page.
  ///
  /// ```dart
  /// onPressed: Wizard.of(context).next
  /// ```
  void next({Object? arguments}) {
    final routes = _getRoutes();
    assert(routes.isNotEmpty, routes.length.toString());

    final previous = routes.last.copyWith(arguments: arguments);

    // advance to a specific route
    String? onNext() => widget._onNext?.call(previous);

    // pick the next route on the list
    String nextRoute() {
      final index = widget._routes.indexOf(previous.name!);
      assert(index < widget._routes.length - 1,
          '`Wizard.next()` called from the last route ${previous.name}.');
      return widget._routes[index + 1];
    }

    final next = RouteSettings(
      name: onNext() ?? nextRoute(),
      arguments: arguments,
    );

    assert(widget._routes.contains(next.name),
        '`Wizard.routes` is missing route \'${next.name}\'.');

    context.flow<List<RouteSettings>>().update((state) {
      final copy = List<RouteSettings>.of(state);
      return copy..add(next);
    });
  }

  List<RouteSettings> _getRoutes() => context.flow<List<RouteSettings>>().state;

  /// Returns `false` if the wizard is currently on the first page.
  bool get hasPrevious => _getRoutes().length > 1;

  /// Returns `false` if the wizard is currently on the last page.
  bool get hasNext => _getRoutes().length < widget._routes.length;

  @override
  Widget build(BuildContext context) {
    return Provider<WizardScopeState>.value(
      value: this,
      child: widget._child,
    );
  }
}
