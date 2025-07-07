import 'package:digital_asset_flutter/features/user_v2/domain/entities/asset.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';

class TransactionQuote {
  final String id;
  final Asset fromAsset;
  final Asset toAsset;
  final Wallet fromWallet;
  final Wallet toWallet;
  final String amountSwap;
  final String amountReceive;
  final String estimatedFee;
  final double rate;
  final String status;
  final DateTime expirationAt;
  final String depositAddress;

  TransactionQuote({
    required this.id,
    required this.fromAsset,
    required this.toAsset,
    required this.fromWallet,
    required this.toWallet,
    required this.amountSwap,
    required this.amountReceive,
    required this.estimatedFee,
    required this.rate,
    required this.status,
    required this.expirationAt,
    required this.depositAddress,
  });

  TransactionQuote copyWith({
    String? id,
    Asset? fromAsset,
    Asset? toAsset,
    Wallet? fromWallet,
    Wallet? toWallet,
    String? amountSwap,
    String? amountReceive,
    String? estimatedFee,
    double? rate,
    String? status,
    DateTime? expirationAt,
    String? depositAddress,
  }) {
    return TransactionQuote(
      id: id ?? this.id,
      fromAsset: fromAsset ?? this.fromAsset,
      toAsset: toAsset ?? this.toAsset,
      fromWallet: fromWallet ?? this.fromWallet,
      toWallet: toWallet ?? this.toWallet,
      amountSwap: amountSwap ?? this.amountSwap,
      amountReceive: amountReceive ?? this.amountReceive,
      estimatedFee: estimatedFee ?? this.estimatedFee,
      rate: rate ?? this.rate,
      status: status ?? this.status,
      expirationAt: expirationAt ?? this.expirationAt,
      depositAddress: depositAddress ?? this.depositAddress,
    );
  }
}
