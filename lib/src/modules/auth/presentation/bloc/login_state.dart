import 'package:morphling/src/modules/auth/presentation/bloc/login_status.dart';
import 'package:morphling/src/modules/auth/domain/models/login_result.dart';

const _missing = Object();

class LoginState<
  TUser extends Object,
  TToken extends Object,
  TCompany extends Object
> {
  const LoginState({
    required this.registrationNumber,
    required this.user,
    required this.password,
    required this.saveData,
    required this.isUseBiometry,
    required this.status,
    required this.tokens,
    required this.companies,
    required this.authorization,
    this.selectedToken,
    this.selectedCompany,
    this.errorMessage,
    this.result,
  });

  const LoginState.initial()
    : registrationNumber = '',
      user = '',
      password = '',
      saveData = false,
      isUseBiometry = false,
      status = LoginStatus.idle,
      tokens = const [],
      companies = const [],
      authorization = '',
      selectedToken = null,
      selectedCompany = null,
      errorMessage = null,
      result = null;

  final String registrationNumber;
  final String user;
  final String password;
  final bool saveData;
  final bool isUseBiometry;
  final LoginStatus status;
  final List<TToken> tokens;
  final List<TCompany> companies;
  final String authorization;
  final TToken? selectedToken;
  final TCompany? selectedCompany;
  final String? errorMessage;
  final LoginResult<TUser, TToken, TCompany>? result;

  bool get canSubmit {
    return registrationNumber.trim().isNotEmpty &&
        user.trim().isNotEmpty &&
        password.trim().isNotEmpty &&
        selectedCompany != null;
  }

  LoginState<TUser, TToken, TCompany> copyWith({
    String? registrationNumber,
    String? user,
    String? password,
    bool? saveData,
    bool? isUseBiometry,
    LoginStatus? status,
    List<TToken>? tokens,
    List<TCompany>? companies,
    String? authorization,
    Object? selectedToken = _missing,
    Object? selectedCompany = _missing,
    Object? errorMessage = _missing,
    Object? result = _missing,
  }) {
    return LoginState<TUser, TToken, TCompany>(
      registrationNumber: registrationNumber ?? this.registrationNumber,
      user: user ?? this.user,
      password: password ?? this.password,
      saveData: saveData ?? this.saveData,
      isUseBiometry: isUseBiometry ?? this.isUseBiometry,
      status: status ?? this.status,
      tokens: tokens ?? this.tokens,
      companies: companies ?? this.companies,
      authorization: authorization ?? this.authorization,
      selectedToken:
          selectedToken == _missing
              ? this.selectedToken
              : selectedToken as TToken?,
      selectedCompany:
          selectedCompany == _missing
              ? this.selectedCompany
              : selectedCompany as TCompany?,
      errorMessage:
          errorMessage == _missing
              ? this.errorMessage
              : errorMessage as String?,
      result:
          result == _missing
              ? this.result
              : result as LoginResult<TUser, TToken, TCompany>?,
    );
  }
}
