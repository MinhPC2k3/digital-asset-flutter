import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/transaction_history_v2/domain/entities/transaction_history.dart';

abstract class TransactionHistoryRepository {
  Future<Result<List<TransactionHistory>?>> getTransactionHistory(String walletId);
}
