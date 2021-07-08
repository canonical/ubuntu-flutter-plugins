import 'package:flutter/material.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:provider/provider.dart';

typedef WizardNextRoute = Future<String> Function(
  BuildContext context, {
  required String route,
});

typedef WizardPageBuilder = Widget Function(
  BuildContext context, {
  required String route,
});

class Wizard extends StatelessWidget {
  const Wizard({
    Key? key,
    required this.initialRoute,
    required this.nextRoute,
    required this.pageBuilder,
  }) : super(key: key);

  final String initialRoute;
  final WizardNextRoute nextRoute;
  final WizardPageBuilder pageBuilder;

  static WizardScopeState of(BuildContext context) {
    return Provider.of<WizardScopeState>(context, listen: false);
  }

  Page _createPage(BuildContext context, {required String route}) {
    return MaterialPage(
      name: route,
      key: ValueKey(route),
      child: WizardScope(
        nextRoute: nextRoute,
        child: pageBuilder(context, route: route),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      child: FlowBuilder<List<String>>(
        state: <String>[initialRoute],
        onGeneratePages: (state, __) {
          return state
              .map((route) => _createPage(context, route: route))
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
    required this.nextRoute,
  }) : super(key: key);

  final Widget child;
  final WizardNextRoute nextRoute;

  @override
  State<WizardScope> createState() => WizardScopeState();
}

class WizardScopeState extends State<WizardScope> {
  Future<void> back() async {
    final routes = context.flow<List<String>>().state;
    assert(routes.length > 1);
    context.flow<List<String>>().update((state) {
      return List<String>.of(state)..removeLast();
    });
  }

  Future<void> next() async {
    final routes = context.flow<List<String>>().state;
    assert(routes.isNotEmpty);
    final route = await widget.nextRoute(context, route: routes.last);
    context.flow<List<String>>().update((state) {
      return List<String>.of(state)..add(route);
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
