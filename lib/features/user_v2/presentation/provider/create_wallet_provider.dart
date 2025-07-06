import 'package:digital_asset_flutter/features/user_v2/data/datasource/network/create_wallet_datasource.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/usecases/create_wallet_usecase.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateWalletProvider extends ChangeNotifier {
  late CreateWalletRepositoryImpl _repo;

  late CreateWalletUsecase _usecase;

  CreateWalletProvider() {
    _repo = CreateWalletRepositoryImpl(client: http.Client());
    _usecase = CreateWalletUsecase(repository: _repo);
  }

  // Form controllers
  final TextEditingController walletNameController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final FocusNode pinFocusNode = FocusNode();

  // State variables
  String selectedNetwork = 'Ethereum';
  List<bool> pinFilledStatus = List.generate(6, (_) => false);
  String? error;
  Wallet? createdWallet;
  bool isLoading = false;

  bool get isFormValid => walletNameController.text.isNotEmpty && pinController.text.length == 6;

  void updatePinFilledStatus() {
    final pin = pinController.text;
    for (int i = 0; i < 6; i++) {
      pinFilledStatus[i] = i < pin.length;
    }
    notifyListeners();
  }

  void setSelectedNetwork(String network) {
    selectedNetwork = network;
    notifyListeners();
  }

  Future<bool> createWallet(String userId) async {
    error = null;
    isLoading = true;
    notifyListeners();

    final result = await _usecase.createWallet(
      userId,
      walletNameController.text,
      selectedNetwork.toLowerCase(),
      pinController.text,
    );

    if (!result.isSuccess) {
      error = result.error?.message;
      notifyListeners();
      return false;
    }

    createdWallet = result.data!;
    return true;
  }

  @override
  void dispose() {
    walletNameController.dispose();
    pinController.dispose();
    pinFocusNode.dispose();
    super.dispose();
  }
}
