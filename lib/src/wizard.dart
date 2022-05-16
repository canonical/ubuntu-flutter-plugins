import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flow_builder/flow_builder.dart';

import 'observer.dart';
import 'result.dart';
import 'route.dart';
import 'scope.dart';
import 'settings.dart';

/// A wizard is a flow of steps that the user can navigate through.
///
/// `Wizard` provides routing for classic linear wizards in a way that it
/// eliminates dependencies between wizard pages. Wizard pages can request the
/// next or previous page without knowing or caring what is the next or the
/// previous wizard page. Thus, adding, removing, or re-ordering pages does not
/// cause changes in existing pages.
///
/// ![wizard_router](https://github.com/ubuntu-flutter-community/wizard_router/raw/main/images/wizard_router.png)
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
    super.key,
    this.initialRoute,
    required this.routes,
    this.observers = const [],
  });

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
  /// If no instance of this class encloses the given context, will cause an
  /// assert in debug mode, and throw an exception in release mode. To return
  /// `null` if there is no wizard scope, use [maybeOf] instead.
  ///
  /// See also:
  /// - [Wizard.maybeOf]
  /// - [WizardScopeState.next]
  /// - [WizardScopeState.arguments]
  /// - [WizardScopeState.back]
  /// - [WizardScopeState.home]
  /// - [WizardScopeState.done]
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

  /// The wizard scope from the closest instance of this class that encloses the
  /// given `context`.
  ///
  /// If no instance of this class encloses the given context, will return
  /// `null`. To throw an exception instead, use [of] instead of this function.
  ///
  /// See also:
  /// - [Wizard.of]
  /// - [WizardScopeState.next]
  /// - [WizardScopeState.arguments]
  /// - [WizardScopeState.back]
  /// - [WizardScopeState.home]
  /// - [WizardScopeState.done]
  static WizardScopeState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<WizardScopeState>();
  }

  final List<WizardObserver> observers;

  @override
  State<Wizard> createState() => _WizardState();
}

class _WizardState extends State<Wizard> {
  late List<WizardRouteSettings> _routes;

  @override
  void initState() {
    super.initState();
    _routes = <WizardRouteSettings>[
      WizardRouteSettings(
          name: widget.initialRoute ?? widget.routes.keys.first),
    ];
  }

  Page _createPage(BuildContext context,
      {required int index, required WizardRouteSettings settings}) {
    return MaterialPage(
      name: settings.name,
      arguments: settings.arguments,
      key: ValueKey(settings.name),
      child: WizardScope(
        index: index,
        route: widget.routes[settings.name]!,
        routes: widget.routes.keys.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<List<WizardRouteSettings>>(
      state: _routes,
      onGeneratePages: (state, __) {
        _routes = state;
        return state
            .mapIndexed((index, settings) =>
                _createPage(context, index: index, settings: settings))
            .toList();
      },
      observers: [_WizardFlowObserver(widget.observers)],
      onComplete: (state) async {
        final result = state.lastOrNull as WizardRouteResult;
        for (final observer in widget.observers) {
          await observer.onDone(result.route, result.result);
        }
      },
    );
  }
}

class _WizardFlowObserver extends NavigatorObserver {
  _WizardFlowObserver(this.observers);

  final List<WizardObserver> observers;

  @override
  void didPush(Route route, Route? previousRoute) {
    for (final observer in observers) {
      observer.onNext(route, previousRoute);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    for (final observer in observers) {
      observer.onBack(previousRoute!, route);
    }
  }
}
