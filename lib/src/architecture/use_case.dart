abstract class IUseCase<Input, Output> {
  Future<Output> call({required Input params});
}

class NoParams {}
