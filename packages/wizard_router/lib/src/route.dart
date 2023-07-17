import 'dart:async';

import 'package:flutter/widgets.dart';

/// The signature of [WizardRoute.onNext] and [WizardRoute.onBack] callbacks.
typedef WizardRouteCallback = FutureOr<String?> Function(
    RouteSettings settings);

/// The signature of [WizardRoute.onLoad] callback.
typedef WizardRouteLoader = FutureOr<bool> Function(RouteSettings settings);

class WizardRoute {
  const WizardRoute({
    required this.builder,
    this.onNext,
    this.onReplace,
    this.onBack,
    this.onLoad,
    this.userData,
  });

  final WidgetBuilder builder;

  /// The callback invoked when the next page is requested.
  ///
  /// If `onNext` is not specified or it returns `null`, the order is determined
  /// from [routes].
  final WizardRouteCallback? onNext;

  /// The callback invoked when a replacement page is requested.
  ///
  /// If `onReplace` is not specified or it returns `null`, the order is
  /// determined from [routes].
  final WizardRouteCallback? onReplace;

  /// The callback invoked when the previous page is requested.
  ///
  /// If `onBack` is not specified or it returns `null`, the order is determined
  /// from [routes].
  final WizardRouteCallback? onBack;

  /// The callback invoked when the page is loaded.
  ///
  /// If `onLoad` is specified and returns `false`, the page is skipped.
  final WizardRouteLoader? onLoad;

  /// Additional custom data associated with this page.
  final Object? userData;
}
