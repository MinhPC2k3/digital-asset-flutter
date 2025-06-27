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
      assetBalances: null
    );
  }
}

class AssetBalanceDTO {
  String id;
  String assetId;
  String assetSymbol;
  String walletId;
  String balance;
  String assetType;

  AssetBalanceDTO({
    required this.id,
    required this.assetId,
    required this.assetSymbol,
    required this.walletId,
    required this.balance,
    required this.assetType,
  });

  factory AssetBalanceDTO.fromJson(Map<String, dynamic> json) {
    return AssetBalanceDTO(
      id: json['id'] ?? '',
      assetId: json['assetId'] ?? '',
      assetSymbol: json['assetSymbol'] ?? '',
      walletId: json['walletId'] ?? '',
      balance: json['balance'] ?? '',
      assetType: json['assetType'] ?? '',
    );
  }

  AssetBalance toDomain() {
    return AssetBalance(
      id: id,
      assetId: assetId,
      assetSymbol: assetSymbol,
      walletId: walletId,
      balance: '',
      assetType: assetType,
      currency: '',
      updatedAt: null,
      last24hChange: 0,
      price: 0,
      assetBalance: balance,
    );
  }
}

class PriceValuationDTO {
  String walletId;
  String assetId;
  String symbol;
  double price;
  String currency;
  DateTime? updatedAt;
  double last24hChange;

  PriceValuationDTO({
    required this.assetId,
    required this.walletId,
    required this.currency,
    required this.updatedAt,
    required this.last24hChange,
    required this.price,
    required this.symbol,
  });

  factory PriceValuationDTO.fromJson(Map<String, dynamic> json) {
    return PriceValuationDTO(
      walletId: json['walletId'] ?? '',
      assetId: json['assetId'] ?? '',
      currency: json['currency'] ?? '',
      symbol: json['symbol'] ?? '',
      updatedAt: parseNullableDateTime(json['updatedAt']),
      last24hChange: json['last24hChange'] ?? '',
      price: json['price'] ?? '',
    );
  }

  AssetBalance toDomain(AssetBalance assetBalance) {
    assetBalance.currency = currency;
    assetBalance.last24hChange = last24hChange;
    assetBalance.updatedAt = updatedAt;
    assetBalance.price = price;
    return assetBalance;
  }
}

DateTime? parseNullableDateTime(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;

  // Remove the second timezone part (if exists)
  final cleaned = dateStr.replaceFirst(RegExp(r' \+\d{2}$'), '');

  return DateTime.tryParse(cleaned);
}