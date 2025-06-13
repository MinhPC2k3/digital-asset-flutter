import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';

class WalletDto {
  String walletId;
  String userId;
  String network;
  String status;
  String walletName;
  String address;
  String walletKey;
  String version;

  WalletDto({
    required this.walletId,
    required this.userId,
    required this.network,
    required this.status,
    required this.walletName,
    required this.address,
    required this.walletKey,
    required this.version,
  });

  factory WalletDto.fromJson(Map<String, dynamic> json) {
    return WalletDto(
      walletId: json['walletId'] ?? '',
      userId: json['userId'] ?? '',
      network: json['network'] ?? '',
      status: json['status'] ?? '',
      walletName: json['walletName'] ?? '',
      address: json['address'] ?? '',
      walletKey: json['walletKey'] ?? '',
      version: json['version'] ?? '',
    );
  }

  Wallet toDomain() {
    return Wallet(
      id: walletId,
      walletId: walletId,
      userId: userId,
      networkId: '',
      networkName: network,
      networkSymbol: '',
      address: address,
      publicKey: '',
      createdAt: null,
      updatedAt: null,
      status: status,
      accountKey: walletKey,
      version: version,
      walletName: walletName,
    );
  }
}
