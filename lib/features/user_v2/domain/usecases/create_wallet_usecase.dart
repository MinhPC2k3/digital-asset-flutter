import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/repositories/create_wallet_repository.dart';

class CreateWalletUsecase {
  final CreateWalletRepository repository;

  CreateWalletUsecase({required this.repository});

  Future<Result<Wallet>> createWallet(
    String userId,
    String walletName,
    String network,
    String walletPin,
  ) async {
    return await repository.createWallet();
  }
}
