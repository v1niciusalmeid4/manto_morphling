abstract class ScreenState<T> {
  final T? data;

  const ScreenState({this.data});
}

class Empty<T> extends ScreenState<T> {
  const Empty({super.data});
}

class Loading<T> extends ScreenState<T> {
  const Loading({super.data});
}

class Stable<T> extends ScreenState<T> {
  const Stable({super.data});
}

class Error<T> extends ScreenState<T> {
  final String message;
  const Error({required this.message, super.data});
}
