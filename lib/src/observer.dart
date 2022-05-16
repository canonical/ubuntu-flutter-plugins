import 'package:flutter/widgets.dart';

/// An interface for observing the behavior of a [Wizard].
abstract class WizardObserver {
  /// The wizard returned from [nextRoute] to [previousRoute].
  void onBack(Route previousRoute, Route? nextRoute);

  /// The wizard moved from [previousRoute] to [nextRoute].
  void onNext(Route nextRoute, Route? previousRoute);
}
