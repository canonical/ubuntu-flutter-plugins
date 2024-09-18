## 1.3.0

> Note: This release has breaking changes.

 - **BREAKING** **CHORE**: Bump to Flutter 3.24.3.

## 1.2.0

 - **FEAT**(wizard_router): add errorRoute and showError().
 - **FEAT**: allow the user to complete the wizard flow.

## 1.1.0

 - **REFACTOR**: Apply ubuntu lints to all packages (#340).
 - **FEAT**: Activate ubuntu_lints.

# Changelog

## [1.0.4](https://github.com/canonical/ubuntu-flutter-plugins/compare/wizard_router-v1.0.3...wizard_router-v1.0.4) (2023-10-19)


* **deps:** update flutter in wizard_router ([73cbbd8](https://github.com/canonical/ubuntu-flutter-plugins/commit/73cbbd84c20cf4e380c7ead59a1a79dd812562e6))

## [1.0.3](https://github.com/canonical/ubuntu-flutter-plugins/compare/wizard_router-v1.0.2...wizard_router-v1.0.3) (2023-07-18)


* **github:** remove old workflows ([154593c](https://github.com/canonical/ubuntu-flutter-plugins/commit/154593c71e41672e830d3dc208231de10fd86b4e))
* mv / packages/wizard_router/ ([e4544bd](https://github.com/canonical/ubuntu-flutter-plugins/commit/e4544bd4dd0980fb8a643f48a001b88cd8c1ff32))
* remove codecov.yaml from newly imported packages ([486f0f6](https://github.com/canonical/ubuntu-flutter-plugins/commit/486f0f696ab14f9d068a1cbae561152834c3a129))
* **renovate:** clean up old renovate configs ([af1126b](https://github.com/canonical/ubuntu-flutter-plugins/commit/af1126ba62d60fb411ddb0b29e326f0f51a6b297))
* update links ([#299](https://github.com/canonical/ubuntu-flutter-plugins/issues/299)) ([e679e3b](https://github.com/canonical/ubuntu-flutter-plugins/commit/e679e3b3a8a6316a0fc56e9695a6798d26f3929b))

## 1.0.2 (2023-07-04)

## What's Changed
* ci: specify flutter version as env var by @jpnurmi in https://github.com/ubuntu-flutter-community/wizard_router/pull/61
* chore(deps): update dependency safe_change_notifier to ^0.3.0 by @renovate in https://github.com/ubuntu-flutter-community/wizard_router/pull/63
* ci: reuse pr title & release actions from ufc/actions by @jpnurmi in https://github.com/ubuntu-flutter-community/wizard_router/pull/64


**Full Changelog**: https://github.com/ubuntu-flutter-community/wizard_router/compare/v1.0.1...v1.0.2

## 1.0.1 (2023-06-16)

## What's Changed
* refactor: replace asserts with exceptions by @jpnurmi in https://github.com/ubuntu-flutter-community/wizard_router/pull/58


**Full Changelog**: https://github.com/ubuntu-flutter-community/wizard_router/compare/v1.0.0...v1.0.1

## 1.0.0 (2023-06-15)

## What's Changed
* Add root argument to Wizard.of() and Wizard.maybeOf() by @jpnurmi in https://github.com/ubuntu-flutter-community/wizard_router/pull/34
* Fix lints by @jpnurmi in https://github.com/ubuntu-flutter-community/wizard_router/pull/35
* Example: enable & fix lints by @jpnurmi in https://github.com/ubuntu-flutter-community/wizard_router/pull/36
* Update CI by @jpnurmi in https://github.com/ubuntu-flutter-community/wizard_router/pull/37
* remove Wizard.done() by @d-loose in https://github.com/ubuntu-flutter-community/wizard_router/pull/38
* Refactor WizardController by @d-loose in https://github.com/ubuntu-flutter-community/wizard_router/pull/39
* remove WizardObserver by @d-loose in https://github.com/ubuntu-flutter-community/wizard_router/pull/40
* add support for optionally async callbacks by @d-loose in https://github.com/ubuntu-flutter-community/wizard_router/pull/41
* WizardController: await potentially async onBack callback by @d-loose in https://github.com/ubuntu-flutter-community/wizard_router/pull/43
* WizardController: return results in jump and replace by @d-loose in https://github.com/ubuntu-flutter-community/wizard_router/pull/44
* WizardScopeState: expose WizardController by @d-loose in https://github.com/ubuntu-flutter-community/wizard_router/pull/45
* README: add controller example by @d-loose in https://github.com/ubuntu-flutter-community/wizard_router/pull/46
* Release 1.0.0-beta by @d-loose in https://github.com/ubuntu-flutter-community/wizard_router/pull/47
* add onLoad callback by @d-loose in https://github.com/ubuntu-flutter-community/wizard_router/pull/48
* Add `isLoading` to `WizardController` and `WizardScopeState` by @d-loose in https://github.com/ubuntu-flutter-community/wizard_router/pull/42
* Restore HeroController by @jpnurmi in https://github.com/ubuntu-flutter-community/wizard_router/pull/49
* Release 1.0.0-beta.2 by @jpnurmi in https://github.com/ubuntu-flutter-community/wizard_router/pull/50
* ci: switch from deprecated `flutter format` to `dart format` by @jpnurmi in https://github.com/ubuntu-flutter-community/wizard_router/pull/52
* onLoad: add return value to allow guarding routes by @jpnurmi in https://github.com/ubuntu-flutter-community/wizard_router/pull/51
* fix(controller): prevent notifying listeners after being disposed by @jpnurmi in https://github.com/ubuntu-flutter-community/wizard_router/pull/55


**Full Changelog**: https://github.com/ubuntu-flutter-community/wizard_router/compare/v0.10.1...v1.0.0

## 1.0.0-beta.3

- onLoad: add return value to allow guarding routes (#51)

## 1.0.0-beta.2

- Add WizardRoute.onLoad callback (#48)
- Add WizardScope.isLoading & WizardController.isLoading (#42)
- Restore HeroController (#49)

## 1.0.0-beta

- Remove Wizard.done() (#38)
- Refactor WizardController (#39)
- Remove WizardObserver, use NavigatorObservers instead (#40)
- Add support for optionally asynchronous callbacks (#41, #43)
- Expose WizardController on WizardScopeState (#45)
- Add WizardController example to README

## 0.10.2

- Add root argument to Wizard.of() and Wizard.maybeOf()

## 0.10.1

- Add WizardScope.jump()

## 0.10.0

- Add WizardController by @chillbrodev (#32)

## 0.9.4

-  Add user data properties to WizardRoute and Wizard (#30)

## 0.9.3

- Remove non-existent routes when rebuilt (#29)

## 0.9.2

- Fix Flutter 3.7.0 compatibility

## 0.9.1

- Add HeroController

## 0.9.0

- Add WizardScope.replace()

## 0.8.1

- Fix WizardScope.hasNext

## 0.8.0

* Add Wizard.maybeOf()
* Add Wizard.done()
* Add WizardObserver
* Upgrade to Flutter 3.0 & Dart 2.17

## 0.7.0+1

* Fix links in README.md

## 0.7.0

* Expose an 'observers' member to enable monitoring a Wizard's navigation.

## 0.6.0

* Remove unnecessary provider dependency.
* Fix Wizard.hasPrevious and Wizard.hasNext.
* Fix Wizard.of() access in immediate route builder context.

## 0.5.0

* Move onNext and onBack to WizardRoute.

## 0.4.0

* Add result argument to Wizard.back()

## 0.3.0

* Add Wizard.home()
* Add Wizard.hasNext and Wizard.hasPrevious

## 0.2.0

* Upgrade to provider 6.0.0 to fix Flutter master compatibility.

## 0.1.0+1

* Update description.

## 0.1.0

* Initial release.
