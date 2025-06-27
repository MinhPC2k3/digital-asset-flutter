import 'package:flutter/cupertino.dart';

class AssetInfo {
  String assetId;
  String assetSymbol;
  String assetType;
  String assetName;
  int decimals;
  String networkName;

  AssetInfo({
    required this.assetId,
    required this.assetSymbol,
    required this.assetType,
    required this.assetName,
    required this.decimals,
    required this.networkName,
  });

  factory AssetInfo.fromJson(Map<String, dynamic> json) {
    return AssetInfo(
      assetId: json['assetId'],
      assetSymbol: json['assetSymbol'],
      assetType: json['assetType'],
      assetName: json['assetName'],
      decimals: json['decimals'] ?? 0,
      networkName: json['networkName'],
    );
  }
}

class AssetProvider extends ChangeNotifier {
  Map<String,AssetInfo>? _assetInfo;

  Map<String,AssetInfo>? get assetInfos => _assetInfo;

  void setAssetInfo(Map<String,AssetInfo> assetInfo) {
    _assetInfo = assetInfo;
    notifyListeners();
  }
}