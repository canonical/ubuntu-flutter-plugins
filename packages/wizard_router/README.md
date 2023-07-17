# Wizard Router for Flutter

[![pub](https://img.shields.io/pub/v/wizard_router.svg)](https://pub.dev/packages/wizard_router)
[![license: BSD](https://img.shields.io/badge/license-BSD-yellow.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![CI](https://github.com/canonical/ubuntu-flutter-plugins/workflows/CI/badge.svg)](https://github.com/canonical/ubuntu-flutter-plugins/actions/workflows/ci.yaml)
[![codecov](https://codecov.io/gh/canonical/ubuntu-flutter-plugins/branch/main/graph/badge.svg)](https://codecov.io/gh/canonical/ubuntu-flutter-plugins)

[wizard_router](https://pub.dev/packages/wizard_router) provides routing for
classic linear wizards in a way that it eliminates dependencies between wizard
pages. Wizard pages can request the next or previous page without knowing or
caring what is the next or the previous wizard page. Thus, adding, removing, or
re-ordering pages does not cause changes in existing pages.

![wizard_router](https://github.com/canonical/ubuntu-flutter-plugins/raw/main/packages/wizard_router/images/wizard_router.png)

## Usage

### Routes

```dart
MaterialApp(
  home: Scaffold(
    body: Wizard(
      routes: {
        '/foo': WizardRoute(builder: (context) => FooPage()),
        '/bar': WizardRoute(builder: (context) => BarPage()),
        '/baz': WizardRoute(builder: (context) => BazPage()),
      },
    ),
  ),
)
```

### Navigation

The next or the previous page is requested by calling `Wizard.of(context).next()`
or `Wizard.of(context).back()`, respectively.

```dart
BarPage(
  child: ButtonBar(
    children: [
      ElevatedButton(
        onPressed: Wizard.of(context).back
        child: const Text('Back'),
      ),
      ElevatedButton(
        onPressed: Wizard.of(context).next
        child: const Text('Next'),
      ),
    ],
  ),
)
```

### Conditions

For unconditional linear wizards, defining the routes is enough. The router
follows the order the routes are defined in. If there are conditions between
the wizard pages, the order can be customized with the `WizardRoute.onNext` and
`WizardRoute.onBack` callbacks.

```dart
Wizard(
  routes: {
    '/foo': WizardRoute(
      builder: (context) => FooPage(),
      // conditionally skip the _Bar_ page when stepping forward from the _Foo_ page
      onNext: (settings) => skipBar ? '/baz' : null,
    ),
    '/bar': WizardRoute(builder: (context) => BarPage()),
    '/baz': WizardRoute(builder: (context) => BazPage()),
    '/qux': WizardRoute(
      builder: (context) => QuxPage(),
      // always skip the Baz page when stepping back from the Qux page
      onBack: (settings) => '/bar',
    ),
  },
)
```

### Arguments

It is recommended to avoid such dependencies between wizard pages that make
assumptions of the page order. However, sometimes it may be desirable to pass
arguments to the next page. This is possible by passing them to
`Wizard.of(context).next(arguments)`. On the next page, the arguments can be
queried from `Wizard.of(context).arguments`.

```dart
FooPage(
  onFoo: () => Wizard.of(context).next(arguments: something),
)

BarPageState extends State<BarPage>(
  @override
  void initState() {
    super.initState();

    final something = Wizard.of(context).arguments as Something;
    // ...
  }
)
```

### Controller

The wizard can be accessed from anywhere in the widget tree by using a `WizardController`.

```dart
class FooPage extends StatefulWidget {
  final _controller = WizardController(
    routes: {
      '/foo': WizardRoute(builder: (context) => FooPage()),
      '/bar': WizardRoute(builder: (context) => BarPage()),
    },
  );
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wizard(controller: _controller),
        ButtonBar(
          children: [
            ElevatedButton(
              onPressed: _controller.back,
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: _controller.next,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }
}
```

## Credits

`wizard_router` is based on [flow_builder](https://pub.dev/packages/flow_builder).
