class Asset {
  final String assetId;
  final String symbol;
  final String balance;
  final int decimals;
  final double valuationUsd;
  final double last24hChange;
  final String networkName;

  Asset({
    required this.assetId,
    required this.symbol,
    required this.balance,
    required this.decimals,
    required this.valuationUsd,
    required this.last24hChange,
    required this.networkName,
  });
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
