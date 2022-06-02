import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

final _locator = GetIt.asNewInstance();

/// Locates and returns an injected service.
T getService<T extends Object>({String? id}) => _locator<T>(instanceName: id);

/// Registers a service with the locator.
void registerService<T extends Object>(
  T Function() create, {
  String? id,
  FutureOr<void> Function(T service)? dispose,
}) {
  unregisterService<T>(id: id);
  _locator.registerLazySingleton<T>(create, dispose: dispose, instanceName: id);
}

/// Registers a service instance with the locator.
void registerServiceInstance<T extends Object>(T service, {String? id}) {
  unregisterService<T>(id: id);
  _locator.registerSingleton<T>(service, instanceName: id);
}

/// Unregisters a service instance with the locator.
void unregisterService<T extends Object>({String? id}) {
  if (_locator.isRegistered<T>(instanceName: id)) {
    _locator.unregister<T>(instanceName: id);
  }
}

/// Registers a mock service for testing purposes.
@visibleForTesting
void registerMockService<T extends Object>(T mock) {
  registerServiceInstance<T>(mock);
}

/// Unregisters a mock service for testing purposes.
@visibleForTesting
void unregisterMockService<T extends Object>({String? id}) {
  unregisterService<T>(id: id);
}
