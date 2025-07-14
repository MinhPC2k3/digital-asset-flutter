import '../../domain/entities/asset.dart';

class AssetDTO {
  final String assetId;
  final String symbol;
  final String balance;
  final int decimals;
  final double valuationUsd;
  final double last24hChange;
  final String networkName;
  final String assetName;

  AssetDTO({
    required this.assetId,
    required this.symbol,
    required this.balance,
    required this.decimals,
    required this.valuationUsd,
    required this.last24hChange,
    required this.networkName,
    required this.assetName,
  });

  factory AssetDTO.fromJson(Map<String, dynamic> json) {
    var symbol = '';
    if (json['assetSymbol'] != null){
      symbol = json['assetSymbol'];
    }else if (json['symbol'] != null){
      symbol = json['symbol'];
    }
    return AssetDTO(
      assetId: json['assetId'] ?? '',
      symbol: symbol,
      balance: json['balance'] ?? '0',
      decimals: json['decimals'] ?? 0,
      valuationUsd: (json['valuationUsd'] ?? 0 as num).toDouble(),
      last24hChange: (json['last24hChange'] ?? 0 as num).toDouble(),
      networkName: json['networkName'] ?? '',
      assetName: json['assetName'] ?? '',
    );
  }

  Asset toEntity() {
    return Asset(
      assetId: assetId,
      symbol: symbol,
      balance: balance,
      decimals: decimals,
      valuationUsd: valuationUsd,
      last24hChange: last24hChange,
      networkName: networkName,
      assetName: assetName,
    );
  }
}
