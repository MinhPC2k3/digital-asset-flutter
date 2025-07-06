import '../../domain/entities/asset.dart';

class NftDTO {
  final String tokenId;
  final String name;
  final String imageUrl;
  final String collection;
  final double estimatedValueUsd;
  final String assetId;

  NftDTO({
    required this.tokenId,
    required this.name,
    required this.imageUrl,
    required this.collection,
    required this.estimatedValueUsd,
    required this.assetId,
  });

  factory NftDTO.fromJson(Map<String, dynamic> json) {
    return NftDTO(
      tokenId: json['tokenId'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      collection: json['collection'],
      estimatedValueUsd: (json['estimatedValueUsd'] as num).toDouble(),
      assetId: json['assetId'] ?? '',
    );
  }

  NFT toEntity() {
    return NFT(
      tokenId: tokenId,
      name: name,
      imageUrl: imageUrl,
      collection: collection,
      estimatedValueUsd: estimatedValueUsd,
      assetId: assetId,
    );
  }
}
