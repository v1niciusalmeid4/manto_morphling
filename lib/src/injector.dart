import 'package:morphling/morphling.dart';

class MorphlingInjector extends DependencyInjector {
  @override
  void dependencies() {
    put<NavigatorService>(NavigatorServiceImpl());
    put<FileService>(FileServiceImpl());
  }
}
