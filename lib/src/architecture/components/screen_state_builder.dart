import 'package:flutter/material.dart';
import '../architecture.dart';

class ScreenStateBuilder<T> extends StatelessWidget {
  final IBloC<dynamic, ScreenState<T>> bloc;
  final Widget Function(BuildContext context, Empty<T> state) onEmpty;
  final Widget Function(BuildContext context, Loading<T> state) onLoading;
  final Widget Function(BuildContext context, Stable<T> state) onStable;
  final Widget Function(BuildContext context, Error<T> state) onError;

  const ScreenStateBuilder({
    required this.bloc,
    required this.onStable,
    required this.onLoading,
    required this.onEmpty,
    required this.onError,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ScreenState<T>>(
      stream: bloc.state,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data;
          if (state is Loading<T>) {
            return onLoading(context, state);
          } else if (state is Stable<T>) {
            return onStable(context, state);
          } else if (state is Empty<T>) {
            return onEmpty(context, state);
          } else if (state is Error<T>) {
            return onError(context, state);
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}
