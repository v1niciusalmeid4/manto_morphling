import 'dart:developer';

import 'package:get_it/get_it.dart';

GetIt _instance = GetIt.asNewInstance();

abstract class IContainerInjector {
  S find<S extends Object>({String? tag});

  void lazyPut<S extends Object>(S Function() builder, {String? tag});

  void put<S extends Object>(S dependency, {String? tag});

  void putAsync<S extends Object>(
    Future<S> Function<S>() builder, {
    String? tag,
  });

  void delete<S extends Object>({String? tag, bool force = false});

  Future<void> reset();
}

class ContainerInjector implements IContainerInjector {
  @override
  void delete<S extends Object>({String? tag, bool force = false}) async {
    log('[Injector::delete]: $S');
    return _instance.unregister(instanceName: tag);
  }

  @override
  S find<S extends Object>({String? tag}) {
    log('[Injector::get]: $S');
    return _instance.get<S>(instanceName: tag);
  }

  @override
  void lazyPut<S extends Object>(S Function() builder, {String? tag}) {
    if (_instance.isRegistered<S>(instanceName: tag)) {
      return;
    }

    log('[Injector::registerFactory]: $S');
    return _instance.registerFactory<S>(builder, instanceName: tag);
  }

  @override
  void put<S extends Object>(S dependency, {String? tag}) {
    if (_instance.isRegistered<S>(instanceName: tag)) {
      return;
    }

    log('[Injector::put]: $S');
    return _instance.registerLazySingleton<S>(
      () => dependency,
      instanceName: tag,
    );
  }

  @override
  void putAsync<S extends Object>(
    Future<S> Function<S>() builder, {
    String? tag,
  }) {
    if (_instance.isRegistered<S>(instanceName: tag)) {
      return;
    }

    log('[Injector::putAsync]: $S');
    return _instance.registerSingletonAsync<S>(builder, instanceName: tag);
  }

  @override
  Future<void> reset() {
    log('[Injector::reset]');
    return _instance.reset();
  }
}
