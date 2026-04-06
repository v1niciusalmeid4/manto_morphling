import 'package:flutter/material.dart';
import 'package:morphling/morphling.dart';

abstract class ComposedScreen<T> {
  final String name;
  final Widget Function(BuildContext) page;
  final DependencyInjector? injector;

  ComposedScreen({
    required this.name,
    required this.page,
    this.injector,
  });
}

class Screen<T> extends ComposedScreen<T> {
  Screen({
    required super.name,
    required super.page,
    super.injector,
  });
}
