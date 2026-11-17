# Standalone Material compatibility

This is a small test application combining the local packages with Yaru. From
this directory, run `fvm flutter test`. It exercises styled push and menu
buttons, a translated button helper, wizard navigation and map interaction.
It is not a run of Ubuntu Installer or App Center.

## Migration snapshot

On 2026-11-17 the fixture passed with Flutter 3.47.6 / Dart 3.13.5,
`material_ui` 1.11.1, `cupertino_ui` 1.1.7, Yaru 12.0.0 and the
`yaru_test` Git revision `b8c7adda79d60e1b5598141d8065b81a795374d6`.
The package test suites also passed using Material 1.11.0 and Cupertino 1.1.6;
`ubuntu_widgets` had 52 tests, `ubuntu_test` 14, `ubuntu_localizations` 36
(including eight from an existing untracked regression file), `wizard_router` 29 and
`timezone_map` 36. The other package test suites passed as well. Melos emitted
an invalid-kernel-cache message before running them but returned success.
The 28 tracked localization tests also passed separately with
`fvm flutter test $(git ls-files 'test/*_test.dart')` from that package.

The fixture passed again with `timezone_map` overridden to Installer's Git
revision `d0d0fec1296b5a4222b32ca3b7b3ce629725176b`. The inspected Installer
[`TimezonePage`](https://github.com/canonical/ubuntu-desktop-provision/blob/2e930a9df596df79218e7a4a583675250da72c59/packages/ubuntu_provision/lib/src/timezone/timezone_page.dart)
uses its medium map, offset, marker and press callback; the fixture exercises
those parameters. It does not exercise the Installer's search, persistence or
full wizard. Its legacy Material page and its pinned dependency versions still
need coordinated consumer migration and testing.

Welsh and Tibetan use the standalone global translations, while additional
Ubuntu locales fall back to the existing Norwegian Bokmål design strings when
the global delegates do not support them. The test verifies loading all Ubuntu
locales, not the correctness of every translation. An application should include
`GlobalUbuntuLocalizations.delegates` along with its generated delegates; Flutter
3.47's generated delegate list alone can contain only the SDK design delegates.
When composing lists, an earlier delegate for the same type and locale wins.

## Consumer and release notes

The three migrated packages have prerelease versions. They can be used together
from this checkout with path dependencies and an `ubuntu_localizations` override,
as shown in this fixture. For another checkout, use Git dependencies with the
appropriate repository commit and package paths instead of local paths. Their
standalone Material types are a breaking change for consumers of SDK Material.

The published `yaru_test` 0.3.5 still targets legacy Material and Yaru <12.
The manifests temporarily pin the migrated Git candidate above; it also calls
itself 0.3.5 but is different from the published package. In particular,
`ubuntu_test` cannot be published with this Git dependency: replace it with a
released, compatible `yaru_test` constraint before publishing. Analysis reports
that dependency warning. Coordinate package releases and update consumers' Yaru
and test-helper constraints accordingly.

`ubuntu_test` retains the old `flutter_markdown` finder because consumers in
this workspace still use that widget. The maintained `flutter_markdown_plus`
also uses SDK Material at the time of this check; changing its finder to that
distinct widget type alone would not remove the compatibility boundary.
