import 'package:flutter/material.dart';
import 'package:morphling/morphling.dart';

abstract class IScreenView<T extends IBloC> extends StatefulWidget {
  const IScreenView({super.key});

  Widget build(BuildContext context, T bloc);

  @override
  State<IScreenView<T>> createState() => _IScreenViewState<T>();
}

class _IScreenViewState<T extends IBloC> extends State<IScreenView<T>> {
  late T bloc;

  @override
  void initState() {
    bloc = ContainerInjector().find<T>();
    bloc.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) => bloc.onReady());
    super.initState();
  }

  @override
  void dispose() {
    bloc.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context, bloc);
  }
}
