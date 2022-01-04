/// This library provides routing for classic linear wizards in a way that it
/// eliminates dependencies between wizard pages. Wizard pages can request the
/// next or previous page without knowing or caring what is the next or the
/// previous wizard page. Thus, adding, removing, or re-ordering pages does not
/// cause changes in existing pages.
///
/// ![wizard_router](https://github.com/jpnurmi/wizard_router/raw/main/images/wizard_router.png)
library wizard_router;

export 'src/wizard.dart';
