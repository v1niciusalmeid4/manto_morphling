sealed class LoginEvent<TToken extends Object, TCompany extends Object> {
  const LoginEvent();
}

class InitRequested<TToken extends Object, TCompany extends Object>
    extends LoginEvent<TToken, TCompany> {
  const InitRequested();
}

class RegistrationNumberChanged<TToken extends Object, TCompany extends Object>
    extends LoginEvent<TToken, TCompany> {
  const RegistrationNumberChanged(this.value);

  final String value;
}

class TokenChanged<TToken extends Object, TCompany extends Object>
    extends LoginEvent<TToken, TCompany> {
  const TokenChanged(this.token);

  final TToken token;
}

class CompanyChanged<TToken extends Object, TCompany extends Object>
    extends LoginEvent<TToken, TCompany> {
  const CompanyChanged(this.company);

  final TCompany? company;
}

class UserChanged<TToken extends Object, TCompany extends Object>
    extends LoginEvent<TToken, TCompany> {
  const UserChanged(this.user);

  final String user;
}

class PasswordChanged<TToken extends Object, TCompany extends Object>
    extends LoginEvent<TToken, TCompany> {
  const PasswordChanged(this.password);

  final String password;
}

class SaveDataChanged<TToken extends Object, TCompany extends Object>
    extends LoginEvent<TToken, TCompany> {
  const SaveDataChanged(this.value);

  final bool value;
}

class BiometricRequested<TToken extends Object, TCompany extends Object>
    extends LoginEvent<TToken, TCompany> {
  const BiometricRequested({this.reason = 'Use a biometria para autenticar'});

  final String reason;
}

class SubmitRequested<TToken extends Object, TCompany extends Object>
    extends LoginEvent<TToken, TCompany> {
  const SubmitRequested();
}

class ResetErrorRequested<TToken extends Object, TCompany extends Object>
    extends LoginEvent<TToken, TCompany> {
  const ResetErrorRequested();
}
