import 'dart:async';

mixin FancyMixin {
  final Map<dynamic, StreamController<dynamic>> _controllers = {};
  final Map<dynamic, List<StreamTransformer<dynamic, dynamic>>> _transforms =
      {};

  void fancyDispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
    _transforms.clear();
  }

  Map get map => _controllers;

  Stream<T> streamOf<T>({dynamic key}) {
    Stream<dynamic> stream = _controllerFor(key).stream;
    final transforms = _transforms[key];

    if (transforms != null) {
      for (final transform in transforms) {
        stream = stream.transform(transform);
      }
    }

    return stream.where((event) => event is T).cast<T>();
  }

  void dispatch<T>(
    T value, {
    dynamic key,
  }) =>
      _controllerFor(key).add(value);

  void dispatchError<T>(
    Object value, {
    dynamic key,
  }) =>
      _controllerFor(key).addError(value);

  void addTransformOn<T, S>(
    StreamTransformer<T, S> streamTransformer, {
    Object? key,
  }) {
    _transforms
        .putIfAbsent(key, () => <StreamTransformer<dynamic, dynamic>>[])
        .add(streamTransformer as StreamTransformer<dynamic, dynamic>);
  }

  StreamSubscription<T> listen<T>(
    void Function(T) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
    Object? key,
  }) => streamOf<T>(key: key).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  StreamController<dynamic> _controllerFor(dynamic key) {
    return _controllers.putIfAbsent(
      key,
      () => StreamController<dynamic>.broadcast(sync: true),
    );
  }
}
