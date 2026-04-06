class LoginRequest<TCompany extends Object> {
  const LoginRequest({
    required this.registrationNumber,
    required this.user,
    required this.password,
    required this.company,
    required this.notificationToken,
    required this.authorization,
  });

  final String registrationNumber;
  final String user;
  final String password;
  final TCompany company;
  final String notificationToken;
  final String authorization;
}
