enum FetchingState {
  loading,
  idle,
  error,
}

extension FetchingStateExtension on FetchingState {
  bool get isLoading => this == FetchingState.loading;
  bool get isError => this == FetchingState.error;
  bool get isIdle => this == FetchingState.idle;
}
