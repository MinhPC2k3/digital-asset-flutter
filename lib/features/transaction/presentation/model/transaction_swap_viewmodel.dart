import 'package:digital_asset_flutter/features/asset/domain/entities/entities.dart';

class TransactionSwapViewmodel {
  AssetInfo sendAssetType;
  AssetInfo receiveAssetType;
  String fromAmount;
  String toAmount;
  String estimateFee;
  DateTime expirationTime;

  TransactionSwapViewmodel({
    required this.sendAssetType,
    required this.receiveAssetType,
    required this.fromAmount,
    required this.toAmount,
    required this.estimateFee,
    required this.expirationTime,
  });
}
