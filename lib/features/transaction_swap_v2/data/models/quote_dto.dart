import 'package:digital_asset_flutter/features/transaction_swap_v2/domain/entities/quote.dart';

class TransactionQuoteDTO {
  final String id;
  final String amountSwap;
  final String amountReceive;
  final String estimatedFee;
  final double rate;
  final String status;
  final int expirationAt;
  final String depositAddress;

  TransactionQuoteDTO({
    required this.id,
    required this.amountSwap,
    required this.amountReceive,
    required this.estimatedFee,
    required this.rate,
    required this.status,
    required this.expirationAt,
    required this.depositAddress,
  });

  factory TransactionQuoteDTO.fromJson(Map<String, dynamic> json) {
    final rateValue = json['rate'];
    double rateParsed = 0.0;

    if (rateValue != null) {
      if (rateValue is int) {
        rateParsed = rateValue.toDouble();
      } else if (rateValue is double) {
        rateParsed = rateValue;
      } else if (rateValue is String) {
        rateParsed = double.tryParse(rateValue) ?? 0.0;
      }
    }

    return TransactionQuoteDTO(
      id: json['quote_id'] ?? '',
      amountSwap: json['send_amount'] ?? '',
      amountReceive: json['receive_amount'] ?? '',
      estimatedFee: json['estimated_fee'] ?? '',
      rate: rateParsed,
      status: json['status'] ?? '',
      expirationAt: json['expiration_time'] ?? 0,
      depositAddress: json['deposit_address'] ?? '',
    );
  }

  TransactionQuote fillEntityField(TransactionQuote txQuote) {
    return txQuote.copyWith(
      id: id,
      fromAsset: null,
      toAsset: null,
      fromWallet: null,
      toWallet: null,
      amountSwap: amountSwap,
      amountReceive: amountReceive,
      estimatedFee: estimatedFee,
      rate: rate,
      status: status,
      depositAddress: depositAddress,
      expirationAt: DateTime.fromMillisecondsSinceEpoch(expirationAt * 1000),
    );
  }
}
