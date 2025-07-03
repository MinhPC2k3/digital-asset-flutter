import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/asset/domain/entities/entities.dart';

abstract class AssetRepository {
  Future<Map<String,AssetInfo>?> getListAssetByNetwork(String networkName);

  Future<Result<List<AssetInfo>>> getListAssets();
}
