import '../../domain/entities/asset.dart';

class AssetDTO {
  final String assetId;
  final String symbol;
  final String balance;
  final int decimals;
  final double valuationUsd;
  final double last24hChange;
  final String networkName;

  AssetDTO({
    required this.assetId,
    required this.symbol,
    required this.balance,
    required this.decimals,
    required this.valuationUsd,
    required this.last24hChange,
    required this.networkName,
  });

  factory AssetDTO.fromJson(Map<String, dynamic> json) {
    return AssetDTO(
      assetId: json['assetId'],
      symbol: json['symbol'],
      balance: json['balance'],
      decimals: json['decimals'],
      valuationUsd: (json['valuationUsd'] as num).toDouble(),
      last24hChange: (json['last24hChange'] as num).toDouble(),
      networkName: json['networkName'] ?? '',
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
    );
  }
}
