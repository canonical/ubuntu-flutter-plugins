import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import 'package:wizard_router/src/exception.dart';
import 'package:wizard_router/src/route.dart';
import 'package:wizard_router/src/scope.dart';
import 'package:wizard_router/src/settings.dart';

part 'controller.dart';

/// A wizard is a flow of steps that the user can navigate through.
///
/// `Wizard` provides routing for classic linear wizards in a way that it
/// eliminates dependencies between wizard pages. Wizard pages can request the
/// next or previous page without knowing or caring what is the next or the
/// previous wizard page. Thus, adding, removing, or re-ordering pages does not
/// cause changes in existing pages.
///
/// ![wizard_router](https://github.com/canonical/ubuntu-flutter-plugins/raw/main/packages/wizard_router/images/wizard_router.png)
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
    this.routes,
    this.observers = const [],
    this.userData,
    this.controller,
  }) : assert((routes == null) != (controller == null),
            'Either routes or controller must be specified');

  /// The name of the first route to show.
  ///
  /// If `initialRoute` not specified, the first route from [routes] is
  /// considered the initial route.
  final String? initialRoute;

  /// The wizards's routing table.
  ///
  /// The order of `routes` is the order of the wizard pages are shown. The
  /// order can be customized with [WizardRoute.onNext] and [WizardRoute.onBack].
  final Map<String, WizardRoute>? routes;

  /// Additional custom data associated with this page.
  final Object? userData;

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
  /// - [WizardScopeState.replace]
  /// - [WizardScopeState.back]
  /// - [WizardScopeState.home]
  static WizardScopeState of(BuildContext context, {bool root = false}) {
    final scope = maybeOf(context, root: root);
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
  /// - [WizardScopeState.replace]
  /// - [WizardScopeState.back]
  /// - [WizardScopeState.home]
  static WizardScopeState? maybeOf(BuildContext context, {bool root = false}) {
    return root
        ? context.findRootAncestorStateOfType<WizardScopeState>()
        : context.findAncestorStateOfType<WizardScopeState>();
  }

  final List<NavigatorObserver> observers;

  final WizardController? controller;

  @override
  State<Wizard> createState() => _WizardState();
}

class _WizardState extends State<Wizard> {
  late WizardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        WizardController(
            routes: widget.routes!, initialRoute: widget.initialRoute);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(Wizard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRoute != oldWidget.initialRoute ||
        widget.controller != oldWidget.controller ||
        !const IterableEquality()
            .equals(widget.routes?.keys, oldWidget.routes?.keys)) {
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ??
          WizardController(
              routes: widget.routes!, initialRoute: widget.initialRoute);
      _controller._flowController.update((state) {
        final newState =
            state.where((r) => _controller.routes.containsKey(r.name)).toList();
        if (newState.isEmpty) {
          newState.add(WizardRouteSettings(
              name: widget.initialRoute ?? _controller.routes.keys.first));
        }
        return newState;
      });
    }
  }

  Page<void> _createPage(
    BuildContext context, {
    required int index,
    required WizardRouteSettings settings,
  }) {
    return MaterialPage(
      name: settings.name,
      arguments: settings.arguments,
      key: ValueKey(settings.name),
      child: WizardScope(
        index: index,
        userData: widget.userData,
        route: _controller.routes[settings.name]!,
        controller: _controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<List<WizardRouteSettings>>(
      controller: _controller._flowController,
      onGeneratePages: (state, __) {
        return state
            .mapIndexed((index, settings) =>
                _createPage(context, index: index, settings: settings))
            .toList();
      },
      observers: [...widget.observers, HeroController()],
    );
  }
}
