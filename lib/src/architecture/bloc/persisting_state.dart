enum PersistingState {
  loading,
  idle,
  error,
}

extension PersistingStateExtension on PersistingState {
  bool get isLoading => this == PersistingState.loading;
  bool get isError => this == PersistingState.error;
  bool get isIdle => this == PersistingState.idle;
}
