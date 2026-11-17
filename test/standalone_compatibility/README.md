# Standalone Material compatibility

This is a small test application combining the local packages with Yaru. From
this directory, run `fvm flutter test`. It exercises styled push and menu
buttons, a translated button helper, wizard navigation and map interaction.
It is not a run of Ubuntu Installer or App Center.

## Migration snapshot

The SDK constraints, required analyzer fixes and formatting are prepared in
`material-ui/00-localizations` (#545), covering six UI-dependent packages and
their three example apps. The localization migration (#544) changes design
types/dependencies and imports in the original tests; it has 26 tracked package
tests. It preserves the pre-existing translation-selection behavior.

Native extra-locale selection and its new all-locales/Tibetan startup
regressions are separate: [issue #551](https://github.com/canonical/ubuntu-flutter-plugins/issues/551),
[SDK-only fix #552](https://github.com/canonical/ubuntu-flutter-plugins/pull/552).
That bug predates the standalone migration; the independent fix is not a
prerequisite for this stack. If it merges first, migrate the new regression
tests' imports when restacking the type migration.

The fixture uses `material_ui` 1.11.1, `cupertino_ui` 1.1.7, Yaru 12.0.0 and
published `yaru_test` 1.0.0.
The repository SDK pin is Flutter 3.47.6 / Dart 3.13.5; package minimums are
Flutter 3.47 / Dart 3.13. The checks after the behavioral split are recorded
in #548.

The fixture passed again with `timezone_map` overridden to Installer's Git
revision `d0d0fec1296b5a4222b32ca3b7b3ce629725176b`. The inspected Installer
[`TimezonePage`](https://github.com/canonical/ubuntu-desktop-provision/blob/2e930a9df596df79218e7a4a583675250da72c59/packages/ubuntu_provision/lib/src/timezone/timezone_page.dart)
uses its medium map, offset, marker and press callback; the fixture exercises
those parameters. It does not exercise the Installer's search, persistence or
full wizard. Its legacy Material page and its pinned dependency versions still
need coordinated consumer migration and testing.

The original localization loading tests put standard delegates first and check
successful loading, not translation correctness. Ubuntu's extra delegates still
unconditionally construct Norwegian Bokmål design strings, even for Welsh and
Tibetan when those delegates are selected. Fix #552 addresses supported native
translations; fallback policy for unsupported locales remains unresolved.
This fixture checks menu/navigation/map compatibility, not all-locale labels.
An application should compose
`AppLocalizations.delegate`, `GlobalUbuntuLocalizations.delegates` and the
standalone `GlobalMaterialLocalizations.delegates`, in that order, instead of
spreading the generated `AppLocalizations.localizationsDelegates` list, which can
still contain SDK design delegates. Consumers must migrate their design widgets
to the standalone packages. When composing lists, an earlier delegate for the
same type and locale wins.

## Consumer and release notes

Package version bumps and matching inter-package constraints are deferred to
`material-ui/05-release`, after the migration and compatibility changes. Until
then, the migrated source retains the existing published version numbers. Use
the packages together from this checkout with path dependencies and an
`ubuntu_localizations` override,
as shown in this fixture. For another checkout, use Git dependencies with the
appropriate repository commit and package paths instead of local paths. Their
standalone Material types are a breaking change for consumers of SDK Material.

The manifests use published `yaru_test: ^1.0.0`, which supports standalone
Material and Yaru 12. This replaces the temporary Git candidate and removes its
publication blocker for `ubuntu_test`. Coordinate package releases and update
consumers' Yaru and test-helper constraints accordingly.

`ubuntu_test` retains the old `flutter_markdown` finder because consumers in
this workspace still use that widget. The maintained `flutter_markdown_plus`
also uses SDK Material at the time of this check; changing its finder to that
distinct widget type alone would not remove the compatibility boundary.
