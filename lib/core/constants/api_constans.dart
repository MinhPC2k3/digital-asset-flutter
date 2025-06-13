class ApiEndpoints {
  static const String profileBaseUrl = 'http://103.161.38.151:18080/v1/auth';
  static const String walletCoreBaseUrl = 'http://103.161.38.151:18080/v1/wallets';
  static const String userBaseUrl = 'http://103.161.38.151:18080/v1/users';

  static const String login = '$profileBaseUrl/login-with-google';
  static const String register = '$profileBaseUrl/register-with-google';
  static const String createWallet = '$walletCoreBaseUrl/create-wallet';
  static const String shareKey = '$walletCoreBaseUrl/share-key';
}
