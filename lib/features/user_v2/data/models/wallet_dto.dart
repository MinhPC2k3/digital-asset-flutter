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
  final String walletKey;
  final String version;

  WalletDTO({
    required this.walletId,
    required this.walletName,
    required this.address,
    required this.networkName,
    required this.assets,
    required this.nfts,
    required this.totalValueUsd,
    required this.walletKey,
    required this.version,
  });

  factory WalletDTO.fromJson(Map<String, dynamic> json) {
    List<NftDTO> temp = [];
    if (json['nfts'] != null) {
      temp = (json['nfts'] as List).map((nft) => NftDTO.fromJson(nft)).toList();
    }
    List<AssetDTO> assetDto = [];
    if (json['assets'] != null) {
      assetDto = (json['assets'] as List).map((asset) => AssetDTO.fromJson(asset)).toList();
    }

    return WalletDTO(
      walletId: json['walletId'],
      walletName: json['walletName'] ?? '',
      address: json['address'] ?? '',
      networkName: json['networkName'] ?? '',
      assets: assetDto,
      nfts: temp,
      totalValueUsd: json['totalValueUsd'] != null ? (json['totalValueUsd'] as num).toDouble() : 0,
      walletKey: json['walletKey'] ?? '',
      version: json['version'] ?? '',
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
      walletKey: walletKey,
      version: version,
      userId: '',
    );
  }

  Wallet toEntityAfterCreate(Wallet currentWallet) {
    currentWallet.version = version;
    currentWallet.walletId = walletId;
    currentWallet.walletKey = walletKey;
    return currentWallet;
  }
}
