## 0.3.2

## 0.3.1

 - **FEAT**: Activate ubuntu_lints.

# Changelog

## [0.3.0](https://github.com/canonical/ubuntu-flutter-plugins/compare/ubuntu_service-v0.2.4...ubuntu_service-v0.3.0) (2023-11-16)


* **ubuntu_service:** Add generics for parameters ([#338](https://github.com/canonical/ubuntu-flutter-plugins/issues/338)) ([762f05c](https://github.com/canonical/ubuntu-flutter-plugins/commit/762f05cefaad72083063c61728a1c4db6daee95b))
* **ubuntu_service:** Add parameter generics ([762f05c](https://github.com/canonical/ubuntu-flutter-plugins/commit/762f05cefaad72083063c61728a1c4db6daee95b))

## [0.2.4](https://github.com/canonical/ubuntu-flutter-plugins/compare/ubuntu_service-v0.2.3...ubuntu_service-v0.2.4) (2023-07-18)


* add changelog titles for release-please ([7ab08b5](https://github.com/canonical/ubuntu-flutter-plugins/commit/7ab08b564ce1c4819f0a5245f9d814baa492e5da))
* fix changelogs ([e80a5a7](https://github.com/canonical/ubuntu-flutter-plugins/commit/e80a5a75e31e983bf6ebad7d7ba76f26f98ccbbc))
* **github:** remove old workflows ([154593c](https://github.com/canonical/ubuntu-flutter-plugins/commit/154593c71e41672e830d3dc208231de10fd86b4e))
* move / packages/ubuntu_service ([019e934](https://github.com/canonical/ubuntu-flutter-plugins/commit/019e934e5161d02a7aaee4d9e71c37bb152a200a))
* remove codecov.yaml from newly imported packages ([486f0f6](https://github.com/canonical/ubuntu-flutter-plugins/commit/486f0f696ab14f9d068a1cbae561152834c3a129))
* **renovate:** clean up old renovate configs ([af1126b](https://github.com/canonical/ubuntu-flutter-plugins/commit/af1126ba62d60fb411ddb0b29e326f0f51a6b297))
* update links ([#299](https://github.com/canonical/ubuntu-flutter-plugins/issues/299)) ([e679e3b](https://github.com/canonical/ubuntu-flutter-plugins/commit/e679e3b3a8a6316a0fc56e9695a6798d26f3929b))

## 0.2.3 (2023-06-14)

## What's Changed
* Update CI by @jpnurmi in https://github.com/ubuntu-flutter-community/ubuntu_service/pull/15
* chore(deps): migrate to get_it 7.4.1+ by @jpnurmi in https://github.com/ubuntu-flutter-community/ubuntu_service/pull/18
* chore: migrate to dart 3 by @jpnurmi in https://github.com/ubuntu-flutter-community/ubuntu_service/pull/17


**Full Changelog**: https://github.com/ubuntu-flutter-community/ubuntu_service/compare/v0.2.2...v0.2.3

## 0.2.2

- Add tryGetService() and tryCreateService().

## 0.2.1

- Add hasService() and tryRegisterService() & friends for conditional
  registration if not already registered.

## 0.2.0

- Add IDs for registering multiple services.
- Ensure independent locator instance.
- Add service factory for creating services with parameters.
- Remove dangerous automatic unregistration.
- Add a way to reset services.

## 0.1.0

- Initial version.
