import 'package:flutter/widgets.dart';

/// The signature of [WizardRoute.onNext] and [WizardRoute.onBack] callbacks.
typedef WizardRouteCallback = String? Function(RouteSettings settings);

class WizardRoute {
  const WizardRoute({
    required this.builder,
    this.onNext,
    this.onBack,
  });

  final WidgetBuilder builder;

  /// The callback invoked when the next page is requested.
  ///
  /// If `onNext` is not specified or it returns `null`, the order is determined
  /// from [routes].
  final WizardRouteCallback? onNext;

  /// The callback invoked when the previous page is requested.
  ///
  /// If `onBack` is not specified or it returns `null`, the order is determined
  /// from [routes].
  final WizardRouteCallback? onBack;
}
