abstract class AuthUiMapper<TToken extends Object, TCompany extends Object> {
  String tokenLabel(TToken token);

  String companyLabel(TCompany company);
}
