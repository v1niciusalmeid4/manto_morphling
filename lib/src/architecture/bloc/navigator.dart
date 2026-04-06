import 'package:flutter/material.dart';

abstract class NavigatorService {
  static final GlobalKey<NavigatorState> key = GlobalKey();

  Future<T?>? toNamed<T>(
    String route, {
    dynamic arguments,
  });

  Future<T?>? offAllNamed<T>(
    String route, {
    dynamic arguments,
  });

  Future<T?>? popAndToNamed<T>(
    String route, {
    dynamic arguments,
    dynamic result,
  });

  void pop<T>({
    T? result,
  });

  void setArguments(Object? args);
  Object? getArguments();

  String getLastRoute();
  String getCurrentRoute();
}

class NavigatorServiceImpl implements NavigatorService {
  Object? arguments;

  String lastRoute = '/';
  String currentRoute = '/';

  BuildContext? get context => NavigatorService.key.currentContext;

  @override
  Future<T?>? toNamed<T>(
    String route, {
    dynamic arguments,
  }) {
    this.arguments = arguments;
    lastRoute = currentRoute;
    currentRoute = route;

    return NavigatorService.key.currentState?.pushNamed(
      route,
      arguments: arguments,
    );
  }

  @override
  Future<T?>? offAllNamed<T>(
    String route, {
    dynamic arguments,
  }) {
    this.arguments = arguments;
    lastRoute = currentRoute;
    currentRoute = route;

    return NavigatorService.key.currentState?.pushNamedAndRemoveUntil(
      route,
      (route) => false,
      arguments: arguments,
    );
  }

  @override
  Future<T?>? popAndToNamed<T>(
    String route, {
    dynamic arguments,
    dynamic result,
  }) {
    this.arguments = arguments;
    lastRoute = currentRoute;
    currentRoute = route;

    return NavigatorService.key.currentState?.popAndPushNamed(
      route,
      arguments: arguments,
      result: result,
    );
  }

  @override
  void pop<T>({
    T? result,
  }) {
    arguments = null;
    final currentState = NavigatorService.key.currentState;
    if (currentState != null && currentState.canPop()) {
      final currentRoute = currentState.overlay?.context.widget;
      if (currentRoute is ModalRoute) {
        currentState.pop(result);
      } else {
        this.currentRoute = lastRoute;
        lastRoute = '/';
        currentState.pop(result);
      }
    }
  }

  @override
  String getCurrentRoute() {
    return currentRoute;
  }

  @override
  String getLastRoute() {
    return lastRoute;
  }

  @override
  Object? getArguments() {
    return arguments;
  }

  @visibleForTesting
  @override
  void setArguments(Object? args) {
    arguments = args;
  }
}
