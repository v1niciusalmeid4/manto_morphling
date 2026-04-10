import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morphling/morphling.dart';

/// Essa classe será utilizada em todas páginas/dialogs que necessitem de lógica
///
/// Utilizar a função [@onReady] para fazer requisições iniciais e inicializar
/// campos e dados.

// ignore: avoid_types_as_parameter_names
abstract class IBloC<Event, ScreenState> with HudMixin {
  late NavigatorService _navigatorService;

  IBloC({ScreenState? initialState}) {
    _event = StreamController<Event>.broadcast();
    _state = StreamController<ScreenState>.broadcast();

    _navigatorService = ContainerInjector().find();

    if (initialState != null) {
      dispatchState(initialState);
    }
  }

  late StreamController<ScreenState> _state;
  Stream<ScreenState> get state => _state.stream;

  late StreamController<Event> _event;
  Stream<Event> get event => _event.stream;

  dynamic getArguments() {
    return _navigatorService.getArguments();
  }

  void pop<T>({T? result}) {
    return _navigatorService.pop<T>(result: result);
  }

  void onReady() {}

  /// cria os [StreamController]s e
  /// inicializa o listener escutando os eventos [@handleEvent]
  void onInit() {
    event.listen(handleEvent);
  }

  void onClose() {
    _state.close();
    _event.close();
  }

  @protected
  void handleEvent(Event event);

  /// Normalmente usado para tratar erros que venham
  /// dos casos de uso
  @protected
  void handleFailure(Failure failure) {
    showFailure(failure.message);
  }

  void dispatchEvent(Event event) => _event.add(event);

  @protected
  void dispatchState(ScreenState state) => _state.add(state);
}
