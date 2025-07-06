import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';

import '../../../../core/network/result.dart';
import '../repositories/homepage_repository.dart';

class HomepageUsecase {
  final HomepageRepository repository;

  HomepageUsecase({required this.repository});

  Future<Result<List<Wallet>>> getListWallet() async {
    return await repository.getWallets();
  }
}
