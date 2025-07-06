import 'package:digital_asset_flutter/features/transaction_history_v2/data/datasource/network/transaction_history_datasource.dart';
import 'package:digital_asset_flutter/features/transaction_history_v2/domain/entities/transaction_history.dart';
import 'package:digital_asset_flutter/features/transaction_history_v2/domain/repositories/transaction_history_repository.dart';
import 'package:digital_asset_flutter/features/transaction_history_v2/domain/usecases/transaction_history_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TransactionHistoryProvider extends ChangeNotifier {
  List<TransactionHistory>? _transactionHistory;
  String? _error;
  bool _isLoading = false;

  late TransactionHistoryRepository _transactionHistoryRepo;
  late TransactionHistoryUsecase _transactionHistoryUsecase;

  bool get isLoading => _isLoading;

  List<TransactionHistory>? get transactionHistory => _transactionHistory;

  String? get error => _error;

  TransactionHistoryProvider() {
    _transactionHistoryRepo = TransactionHistoryImpl(client: http.Client());
    _transactionHistoryUsecase = TransactionHistoryUsecase(repository: _transactionHistoryRepo);
  }

  Future<void> loadTransactionHistory(String address) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      var res = await _transactionHistoryUsecase.getTransactionHistory(address);

      if (!res.isSuccess) {
        _error = res.error!.message;
      } else {
        _transactionHistory = res.data;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
