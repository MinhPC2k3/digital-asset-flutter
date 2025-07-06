import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';

abstract class WalletRepository {
  Future<Result<Wallet>> createWallet(Wallet wallet);

  Future<Result<Wallet>> shareKey(Wallet wallet, String p10, String p12, String p21);

  Future<Result<List<Wallet>>> getUserWallet(String userId);

  Future<Result<List<AssetBalance>>> getAssetBalances(String walletId);

  Future<Result<AssetBalance>> getAssetValuation(String walletId, AssetBalance assetBalances);

  Future<Result<List<NftItem>>> getWalletNft(String walletId, String assetId, String networkName);
}
