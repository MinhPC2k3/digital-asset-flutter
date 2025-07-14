import 'package:digital_asset_flutter/features/user_v2/data/datasource/network/create_wallet_datasource.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/usecases/create_wallet_usecase.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/route.dart';

class CreateWalletProvider extends ChangeNotifier {
  late CreateWalletRepositoryImpl _repo;

  late CreateWalletUsecase _usecase;

  CreateWalletProvider() {
    _repo = CreateWalletRepositoryImpl(client: http.Client());
    _usecase = CreateWalletUsecase(repository: _repo);
  }

  final TextEditingController walletNameController = TextEditingController();

  // Pin controllers
  final TextEditingController pinController = TextEditingController();
  final FocusNode pinFocusNode = FocusNode();
  List<bool> pinFilledStatus = List.generate(6, (_) => false);

  //Confirm pin controller
  final TextEditingController confirmPinController = TextEditingController();
  final FocusNode confirmPinFocusNode = FocusNode();
  List<bool> confirmPinFilledStatus = List.generate(6, (_) => false);

  // State variables
  String selectedNetwork = 'Ethereum';

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

  void updateConfirmPinFilledStatus() {
    final pin = confirmPinController.text;
    for (int i = 0; i < 6; i++) {
      confirmPinFilledStatus[i] = i < pin.length;
    }
    notifyListeners();
  }

  void setSelectedNetwork(String network) {
    selectedNetwork = network;
    notifyListeners();
  }

  Future<bool> createWallet(String userId, BuildContext context) async {
    if(pinController.text != confirmPinController.text){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Confirm pin mismatch'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
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

  // void createWallet(BuildContext context, String userId) async{
  //   final success = await createWallet(userId);
  //   if (success) {
  //     homepageProvider.createNewWallet(provider.createdWallet!);
  //     if (!context.mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Wallet created successfully!'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //     Navigator.pushNamedAndRemoveUntil(
  //       context,
  //       Routes.home,
  //       ModalRoute.withName(Routes.auth),
  //     );
  //   }
  // }
}
