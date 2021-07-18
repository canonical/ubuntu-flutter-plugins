# Wizard Router for Flutter

[wizard_router](https://pub.dev/packages/wizard_router) implements routing for
classic linear wizards in a way that it cuts dependencies between the wizard
pages. Wizard pages merely request the next or previous page in the wizard. They
do not know/care what is the next or previous page in the wizard. Thus, adding,
removing, or re-ordering pages does not cause changes in existing pages.

## Usage

Define routes:

```dart
MaterialApp(
  home: Scaffold(
    body: Wizard(
      routes: [
        '/foo': (context) => FooPage(),
        '/bar': (context) => BarPage(),
        '/baz': (context) => BazPage(),
      ],
    ),
  ),
)
```

The next or previous page is requested by calling `Wizard.of(context).next()` or
`Wizard.of(context).back()`, respectively.

```dart
ButtonBar(
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
)
```

For unconditional linear wizards, defining the routes is enough. If there are
conditions between wizard pages, the page order can be customized by
`Wizard.onNext` and `Wizard.onBack` callbacks.

```dart
Wizard(
  routes: [
    '/foo': (context) => FooPage(),
    '/bar': (context) => BarPage(),
    '/baz': (context) => BazPage(),
    '/qux': (context) => QuxPage(),
  ],
  onNext: (settings) {
    // conditionally skip the _Bar_ page when stepping forward from the _Foo_ page
    if (settings.name == '/foo' && skipBar) return '/baz';
    return null;
  }
  onBack: (settings) {
    // always skip the Baz page when stepping back from the Qux page
    if (settings.name == '/qux') return '/bar';
    return null;
  }
)
```

It is recommended to avoid such dependencies between wizard pages that make
assumptions of the page order. However, sometimes it may be  desirable to pass
arguments to the next page. This is possible by passing them to
`Wizard.of(context).next(arguments)`. On the next page, the arguments can be
queried from `Wizard.of(context).arguments`.

```dart
FooPage(
  onFoo: () => Wizard.of(context).next(something),
)

BarPageState extends State<BarPage>(
  @override
  void initState() {
    super.initState();

    final arguments = Wizard.of(context).arguments as Something;
    // ...
  }
)
```

## Credits

`wizard_router` is based on [flow_builder](https://pub.dev/packages/flow_builder).
