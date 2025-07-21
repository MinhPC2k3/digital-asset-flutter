class Asset {
  final String assetId;
  final String symbol;
  final String balance;
  final int decimals;
  final double valuationUsd;
  final double last24hChange;
  final String networkName;
  final String assetName;

  Asset({
    required this.assetId,
    required this.symbol,
    required this.balance,
    required this.decimals,
    required this.valuationUsd,
    required this.last24hChange,
    required this.networkName,
    required this.assetName,
  });

  @override
  String toString() {
    return 'Asset('
        'assetId: $assetId, '
        'symbol: $symbol, '
        'balance: $balance, '
        'decimals: $decimals, '
        'valuationUsd: $valuationUsd, '
        'last24hChange: $last24hChange, '
        'networkName: $networkName, '
        'assetName: $assetName'
        ')';
  }
}

class NFT {
  final String tokenId;
  final String name;
  final String imageUrl;
  final String collection;
  final double estimatedValueUsd;
  final String assetId;
  final String networkName;

  NFT({
    required this.tokenId,
    required this.name,
    required this.imageUrl,
    required this.collection,
    required this.estimatedValueUsd,
    required this.assetId,
    required this.networkName,
  });
}
