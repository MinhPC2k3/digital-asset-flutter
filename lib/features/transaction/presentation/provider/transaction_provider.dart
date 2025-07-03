import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/asset/domain/entities/entities.dart';
import 'package:digital_asset_flutter/features/transaction/data/source/network/transaction_datasource.dart';
import 'package:digital_asset_flutter/features/transaction/domain/entities/transaction.dart';
import 'package:digital_asset_flutter/features/transaction/domain/usecases/transaction_usecases.dart';
import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionHistoryData>? _transactionHistoryData;
  String? error;
  bool isLoading = false;

  late TransactionRepositoryImpl _txRepo;
  late TransactionUsecase _txUsecase;

  List<TransactionHistoryData>? get txHistory => _transactionHistoryData;

  TransactionProvider() {
    _txRepo = TransactionRepositoryImpl(http.Client());
    _txUsecase = TransactionUsecase(transactionRepository: _txRepo);
  }

  Future<Result<List<TransactionHistoryData>>> loadTransactionHistory(String walletAddress) async {
    print("Doing get tx history from provider");
    var res = await _txUsecase.getTxHistory(walletAddress);
    if (res.isSuccess) {
      _transactionHistoryData = res.data;
      print("Transaction length from usecase ${res.data!.length}");
    }
    return res;
  }

  Future<Result<TransactionSwap>> loadQuote(
    Wallet fromWallet,
    Wallet toWallet,
    AssetInfo fromAsset,
    AssetInfo toAsset,
    String amount,
  ) async {
    var req = TransactionSwap(
      fromAsset: fromAsset,
      toAsset: toAsset,
      fromWallet: fromWallet,
      toWallet: toWallet,
      fromAmount: amount,
      toAmount: '',
      rate: '',
      expirationTimestamp: null,
      depositAddress: '',
      estimatedFee: '',
    );
    return await _txUsecase.getQuote(req);
  }
}
