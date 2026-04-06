import 'package:flutter/material.dart';
import 'package:morphling/morphling.dart';

/// Essa classe será utilizada em todas páginas/dialogs que necessitem de lógica
///
/// Utilizar a função [@onReady] para fazer requisições iniciais e inicializar
/// campos e dados.

abstract class IBloC<Event, State> with FancyMixin, HudMixin {
  IBloC({State? initialState}) {
    if (initialState != null) {
      dispatchState(initialState);
    }
  }

  @visibleForTesting
  Stream<State>? get state => streamOf(key: this);

  @visibleForTesting
  Stream<Event>? get event => streamOf();

  dynamic getArguments() {}

  void pop<T>({T? result}) {}

  void onReady() {}

  /// Start listening to Event and callback on [@handleEvent] function
  /// Dispatch the first state [@Empty]
  void onInit() {
    listen<Event>(handleEvent);
  }

  /// Closes the fancy stream lacks.
  void onClose() {
    fancyDispose();
  }

  Future<void> doPersist({
    required Function action,
    Function(Exception)? onError,
    Function? onFinish,
  }) async {
    try {
      dispatch<PersistingState>(PersistingState.loading);
      await action();
    } on Exception catch (ex) {
      dispatch<PersistingState>(PersistingState.error);
      onError?.call(ex);
    } finally {
      dispatch<PersistingState>(PersistingState.idle);
      onFinish?.call();
    }
  }

  Future<void> doFetch({
    required Function action,
    Function? onError,
    Function? onFinish,
  }) async {
    try {
      dispatch<FetchingState>(FetchingState.loading);
      await action();
    } on Exception catch (_) {
      dispatch<FetchingState>(FetchingState.error);
      onError?.call();
    } finally {
      dispatch<FetchingState>(FetchingState.idle);
      onFinish?.call();
    }
  }

  @protected
  void handleEvent(Event event);

  /// Normaly used for handle failures coming
  /// from usecases
  @protected
  void handleFailure(Failure failure) {
    showFailure(failure.message);
  }

  void dispatchEvent(Event event) => dispatch<Event>(event);

  @protected
  void dispatchState(State state) => dispatch<State>(state, key: this);
}
