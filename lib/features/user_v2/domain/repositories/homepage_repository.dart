import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';

import '../../../../core/network/result.dart';

abstract class HomepageRepository {
  Future<Result<List<Wallet>>> getWallets(String userId);
}
