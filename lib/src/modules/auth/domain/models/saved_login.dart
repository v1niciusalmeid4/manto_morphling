class SavedLogin<TToken extends Object, TCompany extends Object> {
  const SavedLogin({
    required this.registrationNumber,
    required this.user,
    required this.saveData,
    required this.selectedToken,
    required this.selectedCompany,
    required this.encryptedPassword,
  });

  final String registrationNumber;
  final String user;
  final bool saveData;
  final TToken? selectedToken;
  final TCompany? selectedCompany;
  final String encryptedPassword;
}
