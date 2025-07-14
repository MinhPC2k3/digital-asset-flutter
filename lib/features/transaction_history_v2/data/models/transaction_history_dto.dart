import 'package:digital_asset_flutter/features/transaction_history_v2/domain/entities/transaction_history.dart';

class TransactionHistoryDto {
  final String txHash;
  final String blockNumber;
  final String fromAddress;
  final String toAddress;
  final double? value;
  final String tokenType;
  final String tokenSymbol;
  final String? tokenAddress;
  final double? fee;
  final String status;
  final String timestamp;
  final String direction;
  final String explorerUrl;

  TransactionHistoryDto({
    required this.txHash,
    required this.blockNumber,
    required this.fromAddress,
    required this.toAddress,
    this.value,
    required this.tokenType,
    required this.tokenSymbol,
    this.tokenAddress,
    this.fee,
    required this.status,
    required this.timestamp,
    required this.direction,
    required this.explorerUrl,
  });

  factory TransactionHistoryDto.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryDto(
      txHash: json['txHash'],
      blockNumber: json['blockNumber'],
      fromAddress: json['from'],
      toAddress: json['to'],
      value: (json['value'] != null) ? (json['value'] as num).toDouble() : null,
      tokenType: json['tokenType'],
      tokenSymbol: json['tokenSymbol'],
      tokenAddress: json['tokenAddress'] ?? '',
      fee: (json['fee'] != null) ? (json['fee'] as num).toDouble() : null,
      status: json['status'],
      timestamp: json['timestamp'],
      direction: json['direction'],
      explorerUrl: json['explorerUrl'],
    );
  }

  TransactionHistory toDomain() {
    return TransactionHistory(
      txHash: txHash,
      blockNumber: int.parse(blockNumber),
      fromAddress: fromAddress,
      toAddress: toAddress,
      value: value ?? 0,
      tokenType: tokenType,
      tokenSymbol: tokenSymbol,
      fee: fee ?? 0,
      status: status,
      direction: direction,
      explorerUrl: explorerUrl,
      timestamp: DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000),
      timeAgo: '',
    );
  }
}
