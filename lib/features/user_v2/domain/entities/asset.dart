class Asset {
  final String assetId;
  final String symbol;
  final String balance;
  final int decimals;
  final double valuationUsd;
  final double last24hChange;

  Asset({
    required this.assetId,
    required this.symbol,
    required this.balance,
    required this.decimals,
    required this.valuationUsd,
    required this.last24hChange,
  });
}

class NFT {
  final String tokenId;
  final String name;
  final String imageUrl;
  final String collection;
  final double estimatedValueUsd;
  final String assetId;

  NFT({
    required this.tokenId,
    required this.name,
    required this.imageUrl,
    required this.collection,
    required this.estimatedValueUsd,
    required this.assetId,
  });
}
