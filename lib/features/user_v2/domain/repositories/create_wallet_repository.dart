import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';

import '../../../../core/network/result.dart';

abstract class CreateWalletRepository {
  Future<Result<Wallet>> createWallet(Wallet wallet);

  Future<Result<Wallet>> shareKey(Wallet wallet, String p10, String p12, String p21);
}
