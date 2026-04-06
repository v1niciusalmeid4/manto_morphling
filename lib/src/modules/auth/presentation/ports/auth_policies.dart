import 'package:morphling/src/modules/auth/domain/models/login_request.dart';
import 'package:morphling/src/modules/auth/domain/models/login_result.dart';

abstract class AuthPolicy<
  TUser extends Object,
  TToken extends Object,
  TCompany extends Object
> {
  Future<void> beforeLogin(LoginRequest<TCompany> request);

  Future<void> afterLogin(LoginResult<TUser, TToken, TCompany> result);
}

class NoopAuthPolicy<
  TUser extends Object,
  TToken extends Object,
  TCompany extends Object
>
    implements AuthPolicy<TUser, TToken, TCompany> {
  @override
  Future<void> beforeLogin(LoginRequest<TCompany> request) async {}

  @override
  Future<void> afterLogin(LoginResult<TUser, TToken, TCompany> result) async {}
}

abstract class AuthPostLoginHook<
  TUser extends Object,
  TToken extends Object,
  TCompany extends Object
> {
  Future<void> execute(LoginResult<TUser, TToken, TCompany> result);
}

class NoopAuthPostLoginHook<
  TUser extends Object,
  TToken extends Object,
  TCompany extends Object
>
    implements AuthPostLoginHook<TUser, TToken, TCompany> {
  @override
  Future<void> execute(LoginResult<TUser, TToken, TCompany> result) async {}
}
