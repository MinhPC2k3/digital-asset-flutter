import 'package:digital_asset_flutter/core/helper/helper.dart';
import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/transaction_history_v2/presentation/providers/transaction_history_provider.dart';
import 'package:digital_asset_flutter/features/transaction_send_asset_v2/domain/entities/transaction.dart';
import 'package:digital_asset_flutter/features/transaction_swap_v2/data/datasource/transaction_swap_datasource.dart';
import 'package:digital_asset_flutter/features/transaction_swap_v2/domain/entities/quote.dart';
import 'package:digital_asset_flutter/features/transaction_swap_v2/domain/repositories/transaction_swap_repository.dart';
import 'package:digital_asset_flutter/features/transaction_swap_v2/domain/usecases/transaction_swap_usecase.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/asset.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../core/constants/route.dart';
import '../../../user_v2/presentation/provider/homepage_provider.dart';

class SwapProvider extends ChangeNotifier {
  String selectedReceiveToken = 'BNB';
  String selectedReceiveNetwork = "Binance";
  final TextEditingController amountController = TextEditingController();
  String selectedWalletName = "";
  late Wallet receiveSelectedWallet;
  late Asset sendAsset;
  late Asset receiveAsset;
  late List<Asset> listAsset;
  String? validationError;
  double enteredAmount = 0.0;
  List<Wallet> otherWallets = [];
  Wallet? currentWallet;
  bool _isLoading = false;
  String? _error;
  Transaction? transaction;
  List<Wallet>? userWallets;

  String? get error => _error;
  late TransactionSwapRepositoryImpl _repo;

  late TransactionSwapUsecase _usecase;

  bool get isLoading => _isLoading;

  TransactionSwapUsecase get swapUsecase => _usecase;

  // Exchange rates (simplified for demo - token to token conversion)
  final Map<String, double> exchangeRates = {
    'ETH': 2000.0,
    'BTC': 45000.0,
    'BNB': 300.0,
    'ADA': 0.5,
  };

  SwapProvider() {
    amountController.addListener(_onAmountChanged);
    _repo = TransactionSwapRepositoryImpl(client: http.Client());
    _usecase = TransactionSwapUsecase(repository: _repo);
  }

  Future<Result<List<Asset>>> getListAsset() async {
    print("Hello 12345");
    var res = await _usecase.getListAsset();
    if (res.isSuccess) {
      receiveAsset = res.data!.firstWhere((asset) => asset.symbol == 'BNB');
      print("Length of list asset ${res.data!.length}");
    }
    return res;
  }

  void addAmountControllerListener() {
    amountController.addListener(_onAmountChanged);
  }

  void setOtherWallet() {
    print("Rebuild from init state");
    otherWallets = userWallets!.where((w) => w.walletId != currentWallet!.walletId).toList();
    if (otherWallets.isNotEmpty) {
      selectedWalletName =
          '${otherWallets[0].walletName} - ${otherWallets[0].networkName} - ${otherWallets[0].address}';
      receiveSelectedWallet = otherWallets[0];
    }
    sendAsset = currentWallet!.assets[0];
  }

  void _onAmountChanged() {
    String text = amountController.text;
    if (text.isEmpty) {
      enteredAmount = 0.0;
      validationError = null;
      notifyListeners();
      return;
    }

    try {
      double amount = double.parse(text);
      enteredAmount = amount;
      validationError = _validateAmount(amount);
      notifyListeners();
    } catch (e) {
      enteredAmount = 0.0;
      validationError = 'Invalid number format';
      notifyListeners();
    }
  }

  String? _validateAmount(double amount) {
    if (amount < 0) {
      return 'Amount cannot be negative';
    }

    if (amount > double.parse(sendAsset.balance)) {
      return 'Insufficient balance. Available: ${double.parse(sendAsset.balance).toStringAsFixed(6)} ${sendAsset.symbol}';
    }

    if (amount == 0) {
      return 'Amount must be greater than 0';
    }

    return null;
  }

  double calculateReceiveAmount(double sendAmount) {
    double sendRate = exchangeRates[sendAsset.symbol] ?? 0.0;
    double receiveRate = exchangeRates[selectedReceiveToken] ?? 0.0;

    if (receiveRate == 0) return 0.0;

    double usdValue = sendAmount * sendRate;
    return usdValue / receiveRate;
  }

  void setMaximumAmount() {
    amountController.text = double.parse(sendAsset.balance).toStringAsFixed(6);
  }

  void setMinimumAmount() {
    amountController.text = '0.001';
  }

  void updateSendToken(String token, List<Asset> assetInfos) {
    sendAsset = assetInfos.firstWhere((t) => t.symbol == token);
    if (amountController.text.isNotEmpty) {
      _onAmountChanged();
    }
    notifyListeners();
  }

  void updateReceiveToken(String token, List<Asset> assetInfos) {
    selectedReceiveToken = token;
    for (var asset in assetInfos) {
      if (asset.symbol == selectedReceiveToken) {
        selectedReceiveNetwork = receiveSelectedWallet.networkName;
      }
    }
    receiveAsset = assetInfos.firstWhere((t) => t.symbol == token);
    _onAmountChanged();
    notifyListeners();
  }

  void updateSelectedWallet(String walletName) {
    selectedWalletName = walletName;
    receiveSelectedWallet = otherWallets.firstWhere(
      (w) => '${w.walletName} - ${w.networkName} - ${w.address}' == walletName,
    );
    notifyListeners();
  }

  bool get canSwap => validationError == null && enteredAmount > 0;

  @override
  void dispose() {
    amountController.removeListener(_onAmountChanged);
    amountController.dispose();
    super.dispose();
  }

  Future<Result<TransactionQuote>> loadQuote(
    Wallet fromWallet,
    Wallet toWallet,
    Asset fromAsset,
    Asset toAsset,
    String amount,
  ) async {
    _isLoading = true;
    notifyListeners();
    var res = await _usecase.getQuote(
      fromAsset,
      toAsset,
      fromWallet,
      toWallet,
      double.parse(amount),
    );
    if (!res.isSuccess) {
      if (res.error!.message == "wallet not linked to asset (to_asset_id)") {
        _isLoading = false;
        notifyListeners();
        return Result.failure(
          ApiError(
            message: "receive wallet not linked to asset ${toAsset.symbol}",
            statusCode: 400,
          ),
        );
      }
    }
    _isLoading = false;
    notifyListeners();
    return res;
  }

  Future<void> submitTransaction(String pin, Transaction transaction, BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      transaction.transactionType = TransactionType.TX_TYPE_NATIVE_TRANSFER;
      addTransactionTypeV2(transaction);
      final signResponse = await _usecase.prepareSign(transaction);

      if (!signResponse.isSuccess) {
        _error = signResponse.error?.message ?? 'Failed to prepare transaction';
        return;
      }

      var res = await _usecase.sendAsset(transaction, signResponse.data!, pin);
      if (res.isSuccess) {
        var homepageProvider = await Provider.of<HomepageProvider>(context, listen: false);
        homepageProvider.loadUserWallets();
        await Provider.of<TransactionHistoryProvider>(
          context,
          listen: false,
        ).loadTransactionHistory(homepageProvider.currentWallet.address);
        await Future.delayed(Duration(seconds: 2));
        amountController.clear();
        notifyListeners();
        CustomRouter.navigateTo(context, Routes.home);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
