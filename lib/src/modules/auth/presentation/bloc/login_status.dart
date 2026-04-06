enum LoginStatus { idle, loadingRegistration, loadingLogin, success, error }

extension LoginStatusX on LoginStatus {
  bool get isIdle => this == LoginStatus.idle;
  bool get isLoadingRegistration => this == LoginStatus.loadingRegistration;
  bool get isLoadingLogin => this == LoginStatus.loadingLogin;
  bool get isSuccess => this == LoginStatus.success;
  bool get isError => this == LoginStatus.error;
}
