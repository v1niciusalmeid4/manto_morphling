import 'package:morphling/morphling.dart';
import 'package:morphling/src/architecture/architecture.dart';

class MorphlingInjector extends DependencyInjector {
  @override
  void dependencies() {
    put<NavigatorService>(NavigatorServiceImpl());
  }
}
