import 'package:morphling/src/modules/auth/domain/models/login_request.dart';
import 'package:morphling/src/modules/auth/domain/models/saved_login.dart';

abstract class AuthCatalogGateway<
  TToken extends Object,
  TCompany extends Object
> {
  Future<List<TToken>> fetchTokens(String registrationNumber);

  Future<String> fetchAuthorization(TToken token);

  Future<List<TCompany>> fetchCompanies(String authorization);
}

abstract class AuthSessionGateway<
  TUser extends Object,
  TCompany extends Object
> {
  Future<TUser> login(LoginRequest<TCompany> request);
}

abstract class CredentialVault<TToken extends Object, TCompany extends Object> {
  Future<SavedLogin<TToken, TCompany>?> load();

  Future<void> save(SavedLogin<TToken, TCompany> savedLogin);

  Future<void> clear();

  Future<bool> isBiometryEnabled();

  Future<String?> readEncryptedPassword();
}

abstract class NotificationTokenProvider {
  Future<String> getNotificationToken();
}

abstract class PasswordCipher {
  String encrypt(String rawPassword);

  String decrypt(String encryptedPassword);
}

abstract class BiometricGateway {
  Future<bool> isAvailable();

  Future<bool> authenticate({required String reason});
}
