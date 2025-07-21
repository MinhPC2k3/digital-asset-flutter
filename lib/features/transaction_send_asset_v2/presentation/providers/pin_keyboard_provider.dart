import 'package:digital_asset_flutter/features/transaction_send_asset_v2/presentation/providers/transaction_send_asset_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../transaction_history_v2/presentation/providers/transaction_history_provider.dart';
import '../../../user_v2/presentation/provider/homepage_provider.dart';
import '../../data/datasource/network/transaction_send_asset.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_send_asset_repository.dart';
import '../../domain/usecases/transaction_send_asset_usecase.dart';

class PinKeyboardProvider extends ChangeNotifier {
  final TextEditingController pinController = TextEditingController();
  final int pinLength = 6;
  bool isLoading = false;
  final SignInfo signInfo;
  final Transaction transaction;
  late TransactionSendAssetRepository _repository;
  late TransactionSendAssetUsecase _usecase;

  PinKeyboardProvider({required this.signInfo, required this.transaction}) {
    pinController.addListener(notifyListeners);
    _repository = TransactionSendAssetRepositoryImpl(http.Client());
    _usecase = TransactionSendAssetUsecase(repository: _repository);
  }

  bool get isPinComplete => pinController.text.length == pinLength;

  Future<bool> submitPin(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      await _usecase.sendAsset(transaction, signInfo, pinController.text);
      var homepageProvider = Provider.of<HomepageProvider>(context, listen: false);
      var sendAssetTransaction = Provider.of<TransactionSendAssetProvider>(context, listen: false);
      await homepageProvider.loadUserWallets();
      await Provider.of<TransactionHistoryProvider>(
        context,
        listen: false,
      ).loadTransactionHistory(homepageProvider.currentWallet.address);
      await Future.delayed(Duration(seconds: 2));
      pinController.clear();
      sendAssetTransaction.amountController.clear();
      sendAssetTransaction.addressController.clear();
      sendAssetTransaction.isValidAddress = false;
      sendAssetTransaction.isValidAmount = false;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    pinController.removeListener(notifyListeners);
    pinController.dispose();
    super.dispose();
  }
}
