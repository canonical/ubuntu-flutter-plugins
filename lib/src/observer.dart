import 'dart:async';

import 'package:flutter/widgets.dart';

/// An interface for observing the behavior of a [Wizard].
class WizardObserver {
  /// The wizard was initialized to [route].
  void onInit(Route route) {}

  /// The wizard returned to [route] from [previousRoute].
  void onBack(Route route, Route previousRoute) {}

  /// The wizard moved to [route] from [previousRoute].
  void onNext(Route route, Route previousRoute) {}

  /// The wizard was done at [route].
  FutureOr<void> onDone(Route route, Object? result) {}
}
