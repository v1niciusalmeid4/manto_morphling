class LoginResult<
  TUser extends Object,
  TToken extends Object,
  TCompany extends Object
> {
  const LoginResult({
    required this.user,
    required this.token,
    required this.company,
    required this.registrationNumber,
    required this.authorization,
  });

  final TUser user;
  final TToken token;
  final TCompany company;
  final String registrationNumber;
  final String authorization;
}
