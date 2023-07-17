import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

final _locator = GetIt.asNewInstance();

/// Locates and returns an injected service.
T getService<T extends Object>({String? id}) => _locator<T>(instanceName: id);

/// Locates and returns an injected service or null if not found.
T? tryGetService<T extends Object>({String? id}) {
  return hasService<T>(id: id) ? getService<T>(id: id) : null;
}

/// Locates and invokes an injected service factory.
T createService<T extends Object>(dynamic param, {String? id}) {
  return _locator<T>(param1: param, instanceName: id);
}

/// Locates and invokes an injected service factory or returns null if not found.
T? tryCreateService<T extends Object>(dynamic param, {String? id}) {
  return hasService<T>(id: id) ? createService<T>(param, id: id) : null;
}

/// Returns whether a service is registered with the locator.
bool hasService<T extends Object>({String? id}) {
  return _locator.isRegistered<T>(instanceName: id);
}

/// Registers a service with the locator.
void registerService<T extends Object>(
  T Function() create, {
  String? id,
  FutureOr<void> Function(T service)? dispose,
}) {
  _locator.registerLazySingleton<T>(create, dispose: dispose, instanceName: id);
}

/// Registers a service with the locator but only if not already registered.
void tryRegisterService<T extends Object>(
  T Function() create, {
  String? id,
  FutureOr<void> Function(T service)? dispose,
}) {
  if (!hasService<T>(id: id)) {
    registerService<T>(create, id: id, dispose: dispose);
  }
}

/// Locates and resets an injected service.
void resetService<T extends Object>({
  String? id,
  FutureOr<void> Function(T service)? dispose,
}) {
  _locator.resetLazySingleton<T>(instanceName: id, disposingFunction: dispose);
}

/// Resets and disposes all registered services.
Future<void> resetAllServices() => _locator.reset();

/// Registers a service instance with the locator.
void registerServiceInstance<T extends Object>(T service, {String? id}) {
  _locator.registerSingleton<T>(service, instanceName: id);
}

/// Registers a service instance with the locator but only if not already registered.
void tryRegisterServiceInstance<T extends Object>(T service, {String? id}) {
  if (!hasService<T>(id: id)) {
    registerServiceInstance<T>(service, id: id);
  }
}

/// Registers a service factory with the locator.
void registerServiceFactory<T extends Object>(
  T Function(dynamic param) create, {
  String? id,
}) {
  _locator.registerFactoryParam<T, Object?, Object?>(
    (param, _) => create(param),
    instanceName: id,
  );
}

/// Registers a service factory with the locator but only if not already registered.
void tryRegisterServiceFactory<T extends Object>(
  T Function(dynamic param) create, {
  String? id,
}) {
  if (!hasService<T>(id: id)) {
    registerServiceFactory<T>(create, id: id);
  }
}

/// Unregisters a service instance with the locator.
void unregisterService<T extends Object>({
  String? id,
  FutureOr<void> Function(T service)? dispose,
}) {
  if (hasService<T>(id: id)) {
    _locator.unregister<T>(instanceName: id, disposingFunction: dispose);
  }
}

/// Registers a mock service for testing purposes.
@visibleForTesting
void registerMockService<T extends Object>(T mock, {String? id}) {
  unregisterService<T>(id: id);
  registerServiceInstance<T>(mock);
}

/// Unregisters a mock service for testing purposes.
@visibleForTesting
void unregisterMockService<T extends Object>({String? id}) {
  unregisterService<T>(id: id);
}
