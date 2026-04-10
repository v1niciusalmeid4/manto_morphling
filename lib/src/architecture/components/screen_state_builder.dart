import 'package:flutter/material.dart';
import '../architecture.dart';

class ScreenStateBuilder extends StatelessWidget {
  final IBloC bloc;
  final Widget Function(BuildContext context, Empty state) onEmpty;
  final Widget Function(BuildContext context, Loading state) onLoading;
  final Widget Function(BuildContext context, Stable state) onStable;
  final Widget Function(BuildContext context, Error state) onError;

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
    return StreamBuilder<ScreenState>(
      stream: bloc.state as Stream<ScreenState>,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data;
          if (state is Loading) {
            return onLoading(context, state);
          }
          if (state is Stable) {
            return onStable(context, state);
          }
          if (state is Empty) {
            return onEmpty(context, state);
          }
          if (state is Error) {
            return onError(context, state);
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}
