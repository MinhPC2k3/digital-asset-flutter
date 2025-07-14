class ApiEndpoints {
  static const String host = 'https://asset.openledger.vn';
  static const String profileBaseUrl = '$host/v1/auth';
  static const String walletCoreBaseUrl = '$host/v1/wallets';
  static const String userBaseUrl = '$host/v1/users';

  static const String login = '$profileBaseUrl/login-with-google';
  static const String register = '$profileBaseUrl/register-with-google';
  static const String createWallet = '$walletCoreBaseUrl/create-wallet';
  static const String shareKey = '$walletCoreBaseUrl/share-key';
  static const String buildRawTx = '$walletCoreBaseUrl/raw-transaction';
  static const String prepareSign = '$walletCoreBaseUrl/sign/prepare';
  static const String invokeSign = '$walletCoreBaseUrl/sign/invoke';
  static const String combineSignature = '$walletCoreBaseUrl/sign/combine';
  static const String sendAsset = '$walletCoreBaseUrl/transaction/send-asset';
  static const String nftList = '$walletCoreBaseUrl/nft/list';
  static const String listAllAssets = '$walletCoreBaseUrl/all/assets';
  static const String getQuote = '$walletCoreBaseUrl/swap/quote';
}

class ApiEndpointsV2 {
  static const String bffHost = 'http://10.0.2.2:8080';
  static const String host = 'https://asset.openledger.vn';

  static const String walletCoreBaseBffUrl = '$bffHost/v1/wallets';
  static const String assetCoreBaseBffUrl = '$bffHost/v1/assets';
  static const String walletCoreBaseUrl = '$host/v1/wallets';

  static const String getUserWalletUrl = walletCoreBaseBffUrl;
  static const String getTransactionHistory = '$walletCoreBaseBffUrl/transactions/history';
  static const String getSwapQuote = '$assetCoreBaseBffUrl/quote';
  static const String listAllAssets = '$walletCoreBaseUrl/all/assets';

}
