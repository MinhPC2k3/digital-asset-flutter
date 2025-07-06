import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../data/datasource/network/homepage_datasource.dart';
import '../../domain/usecases/homepage_usecase.dart';

class HomepageProvider extends ChangeNotifier {
  late HomepageRepositoriesImpl _repo = HomepageRepositoriesImpl(client: http.Client());
  late HomepageUsecase _usecase = HomepageUsecase(repository: _repo);

  HomepageProvider() {
    _repo = HomepageRepositoriesImpl(client: http.Client());
    _usecase = HomepageUsecase(repository: _repo);
  }

  List<Wallet> _wallets = [];
  bool _isLoading = false;
  Wallet _selectedWallet = Wallet(
    walletId: '',
    walletName: '',
    address: '',
    networkName: '',
    assets: [],
    nfts: [],
    totalValue: 0,
  );
  String? _error;

  List<Wallet> get getWallets => _wallets;

  Wallet get currentWallet => _selectedWallet;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadUserWallets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print("Doing loadUserWallets");
    var res = await _usecase.getListWallet();
    if (!res.isSuccess) {
      _error = res.error!.message;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _wallets = res.data!;
    print("HomepageProvider User wallet length ${_wallets.length}");
    if (_wallets.isNotEmpty) {
      _selectedWallet = _wallets[0];
    }
    _isLoading = false;
    notifyListeners();
  }

  void changeCurrentWallet(int index) {
    _selectedWallet = _wallets[index];
    notifyListeners();
  }

  void createNewWallet(Wallet wallet) {
    _wallets.add(wallet);
    _selectedWallet = _wallets[_wallets.length - 1];
    notifyListeners();
  }
}
