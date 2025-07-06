import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/datasource/network/transaction_send_asset.dart';
import '../../domain/entities/transaction.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../../wallet/domain/usecases/wallet_usecase.dart';
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

  PinKeyboardProvider({
    required this.signInfo,
    required this.transaction,

  }) {
    pinController.addListener(notifyListeners);
    _repository = TransactionSendAssetRepositoryImpl(http.Client());
    _usecase = TransactionSendAssetUsecase(repository: _repository);
  }

  bool get isPinComplete => pinController.text.length == pinLength;

  Future<bool> submitPin(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      await _usecase.sendAsset(
        transaction,
        signInfo,
        pinController.text,
      );

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