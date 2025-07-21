import 'package:digital_asset_flutter/core/helper/helper.dart';
import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/transaction_history_v2/domain/entities/transaction_history.dart';
import '../repositories/transaction_history_repository.dart';

class TransactionHistoryUsecase {
  final TransactionHistoryRepository repository;

  TransactionHistoryUsecase({required this.repository});

  Future<Result<List<TransactionHistory>?>> getTransactionHistory(String walletAddress) async {
    var res = await repository.getTransactionHistory(walletAddress);
    if (res.isSuccess) {
      if (res.data!.isNotEmpty) {
        for (int i = 0; i < res.data!.length; i++) {
          res.data![i].timeAgo = getTimeAgo(res.data![i].timestamp);
        }
      }
    }

    return res;
  }
}
