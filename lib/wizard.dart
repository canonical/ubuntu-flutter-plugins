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

class Wizard extends StatefulWidget {
  const Wizard({
    Key? key,
    required this.initialRoute,
    required this.nextRoute,
    required this.pageBuilder,
  }) : super(key: key);

  final String initialRoute;
  final WizardNextRoute nextRoute;
  final WizardPageBuilder pageBuilder;

  static void back(BuildContext context) {
    Provider.of<_WizardState>(context, listen: false)._back(context);
  }

  static void next(BuildContext context) {
    Provider.of<_WizardState>(context, listen: false)._next(context);
  }

  @override
  State<Wizard> createState() => _WizardState();
}

class _WizardState extends State<Wizard> {
  void _back(BuildContext context) {
    final routes = context.flow<List<String>>().state;
    assert(routes.isNotEmpty);
    context.flow<List<String>>().update((state) {
      return List<String>.of(state)..removeLast();
    });
  }

  Future<void> _next(BuildContext context) async {
    final routes = context.flow<List<String>>().state;
    assert(routes.isNotEmpty);
    final route = await widget.nextRoute(context, route: routes.last);
    context.flow<List<String>>().update((state) {
      return List<String>.of(state)..add(route);
    });
  }

  Page _createPage(BuildContext context, {required String route}) {
    return MaterialPage(
      name: route,
      key: ValueKey(route),
      child: widget.pageBuilder(context, route: route),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      child: FlowBuilder<List<String>>(
        state: <String>[widget.initialRoute],
        onGeneratePages: (state, __) {
          return state
              .map((route) => _createPage(context, route: route))
              .toList();
        },
      ),
    );
  }
}
