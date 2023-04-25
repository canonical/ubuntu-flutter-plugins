import 'package:flutter/foundation.dart';

/// The set of actions that a controller can accept
enum WizardControllerAction {
  home,
  back,
  next,
  replace,
  done,
  unknown,
}

/// Allows widgets such as the AppBar to invoke functionality on the Wizard
/// This is useful for widgets that are defined above the Wizard, such as a mobile
/// app's AppBar.
class WizardController extends ChangeNotifier {
  WizardControllerAction action = WizardControllerAction.unknown;
  Object? arguments;

  /// Since each Page is wrapped with WizardScope we must ensure there is only
  /// ever one listener. This overrides ensures there is only one listener.
  /// Since the WizardScope takes in the Controller, the listener can be
  /// added N times, depending on how many routes are generated.
  @override
  void addListener(VoidCallback listener) {
    if (!hasListeners) {
      super.addListener(listener);
    }
  }

  void home() {
    action = WizardControllerAction.home;
    notifyListeners();
  }

  void done({Object? result}) {
    action = WizardControllerAction.done;
    arguments = result;
    notifyListeners();
  }

  void replace({Object? arguments}) {
    action = WizardControllerAction.replace;
    this.arguments = arguments;
    notifyListeners();
  }

  void next({Object? arguments}) {
    action = WizardControllerAction.next;
    this.arguments = arguments;
    notifyListeners();
  }

  void back({Object? arguments}) {
    action = WizardControllerAction.back;
    this.arguments = arguments;
    notifyListeners();
  }
}
