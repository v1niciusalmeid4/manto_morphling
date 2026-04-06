abstract class ScreenState<T> {
  final T? data;

  ScreenState({
    this.data,
  });
}

class Empty<T> extends ScreenState {
  Empty({super.data});
}

class Loading<T> extends ScreenState {
  Loading({super.data});
}

class Stable<T> extends ScreenState {
  Stable({super.data});
}

class Error<T> extends ScreenState {
  final String message;
  Error({required this.message, super.data});
}
