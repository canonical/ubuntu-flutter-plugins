/// This library provides routing for classic linear wizards in a way that it
/// eliminates dependencies between wizard pages. Wizard pages can request the
/// next or previous page without knowing or caring what is the next or the
/// previous wizard page. Thus, adding, removing, or re-ordering pages does not
/// cause changes in existing pages.
///
/// ![wizard_router](https://github.com/canonical/ubuntu-flutter-plugins/raw/main/packages/wizard_router/images/wizard_router.png)
library wizard_router;

export 'src/exception.dart';
export 'src/route.dart';
export 'src/scope.dart';
export 'src/wizard.dart';
