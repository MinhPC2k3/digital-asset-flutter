import 'package:digital_asset_flutter/features/transaction_swap_v2/domain/entities/quote.dart';

class TransactionQuoteDTO {
  final String id;
  final double amountSwap;
  final double amountReceive;
  final double estimatedFee;
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
      id: json['quoteId'] ?? '',
      amountSwap: (json['sendAmount'] ?? '0' as num).toDouble(),
      amountReceive: (json['receiveAmount'] ?? '0' as num).toDouble(),
      estimatedFee: (json['estimatedFee'] ?? '0' as num).toDouble(),
      rate: rateParsed,
      status: json['status'] ?? '',
      expirationAt: json['expirationTime'] ?? 0,
      depositAddress: json['depositAddress'] ?? '',
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
