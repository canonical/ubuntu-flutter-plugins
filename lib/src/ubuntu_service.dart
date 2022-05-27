import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

final _locator = GetIt.instance;

/// Locates and returns an injected service.
T getService<T extends Object>() => _locator<T>();

/// Registers a service with the locator.
void registerService<T extends Object>(
  T Function() create, {
  FutureOr<void> Function(T service)? dispose,
}) {
  if (_locator.isRegistered<T>()) _locator.unregister<T>();
  _locator.registerLazySingleton<T>(create, dispose: dispose);
}

/// Registers a service instance with the locator.
void registerServiceInstance<T extends Object>(T service) {
  if (_locator.isRegistered<T>()) _locator.unregister<T>();
  _locator.registerSingleton<T>(service);
}

/// Registers a mock service for testing purposes.
@visibleForTesting
void registerMockService<T extends Object>(T mock) {
  registerServiceInstance<T>(mock);
}

/// Unregisters a mock service for testing purposes.
@visibleForTesting
void unregisterMockService<T extends Object>() {
  if (_locator.isRegistered<T>()) _locator.unregister<T>();
}
