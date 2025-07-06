import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';

import 'asset_dto.dart';
import 'nft_dto.dart';

class WalletDTO {
  final String walletId;
  final String walletName;
  final String address;
  final String networkName;
  final List<AssetDTO> assets;
  final List<NftDTO>? nfts;
  final double totalValueUsd;

  WalletDTO({
    required this.walletId,
    required this.walletName,
    required this.address,
    required this.networkName,
    required this.assets,
    required this.nfts,
    required this.totalValueUsd,
  });

  factory WalletDTO.fromJson(Map<String, dynamic> json) {
    List<NftDTO> temp = [];
    if (json['nfts'] != null) {
      temp = (json['nfts'] as List).map((nft) => NftDTO.fromJson(nft)).toList();
    }
    return WalletDTO(
      walletId: json['walletId'],
      walletName: json['walletName'],
      address: json['address'],
      networkName: json['networkName'],
      assets: (json['assets'] as List).map((asset) => AssetDTO.fromJson(asset)).toList(),
      nfts: temp.isEmpty ? null : temp,
      totalValueUsd: (json['totalValueUsd'] as num).toDouble(),
    );
  }

  Wallet toEntity() {
    return Wallet(
      walletId: walletId,
      walletName: walletName,
      address: address,
      networkName: networkName,
      assets: assets.map((asset) => asset.toEntity()).toList(),
      nfts: nfts?.map((nft) => nft.toEntity()).toList(),
      totalValue: totalValueUsd,
    );
  }
}
