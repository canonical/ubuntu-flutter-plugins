import 'package:flutter/material.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:provider/provider.dart';

typedef WizardRouteCallback = String? Function(RouteSettings settings);

class Wizard extends StatefulWidget {
  const Wizard({
    Key? key,
    required this.initialRoute,
    required this.routes,
    this.onNext,
    this.onBack,
  }) : super(key: key);

  final String initialRoute;
  final Map<String, WidgetBuilder> routes;
  final WizardRouteCallback? onNext;
  final WizardRouteCallback? onBack;

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
    _routes = <RouteSettings>[RouteSettings(name: widget.initialRoute)];
  }

  Page _createPage(BuildContext context, {required RouteSettings settings}) {
    final route = settings.name;
    final builder = widget.routes[route];
    assert(builder != null, '`Wizard.routes` is missing route \'$route\'.');

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

class WizardScope extends StatefulWidget {
  const WizardScope({
    Key? key,
    required this.child,
    required this.routes,
    this.onNext,
    this.onBack,
  }) : super(key: key);

  final Widget child;
  final List<String> routes;
  final WizardRouteCallback? onNext;
  final WizardRouteCallback? onBack;

  @override
  State<WizardScope> createState() => WizardScopeState();
}

class WizardScopeState extends State<WizardScope> {
  void back() {
    final routes = context.flow<List<RouteSettings>>().state;
    assert(routes.length > 1,
        '`Wizard.back()` called from the first route ${routes.last.name}');

    // go back to a specific route, or pick the previous route on the list
    final previous = widget.onBack?.call(routes.last);
    final start = previous != null
        ? routes.lastIndexWhere((settings) => settings.name == previous) + 1
        : routes.length - 1;

    context.flow<List<RouteSettings>>().update((state) {
      final copy = List<RouteSettings>.of(state);
      return copy..replaceRange(start, routes.length, []);
    });
  }

  void next({Object? arguments}) {
    final routes = context.flow<List<RouteSettings>>().state;
    assert(routes.isNotEmpty, routes.length.toString());

    final previous = routes.last.copyWith(arguments: arguments);

    // advance to a specific route
    String? onNext() => widget.onNext?.call(previous);

    // pick the next route on the list
    String nextRoute() {
      final index = widget.routes.indexOf(previous.name!);
      assert(index < widget.routes.length - 1,
          '`Wizard.next()` called from the last route ${previous.name}.');
      return widget.routes[index + 1];
    }

    final next = RouteSettings(
      name: onNext() ?? nextRoute(),
      arguments: arguments,
    );

    context.flow<List<RouteSettings>>().update((state) {
      final copy = List<RouteSettings>.of(state);
      return copy..add(next);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider<WizardScopeState>.value(
      value: this,
      child: widget.child,
    );
  }
}
