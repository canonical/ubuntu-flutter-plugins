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
