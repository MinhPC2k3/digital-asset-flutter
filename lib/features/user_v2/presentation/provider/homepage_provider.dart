import 'dart:async';

import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String _userId = '';
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
    userId: '',
    walletKey: '',
    version: '',
  );
  String? _error;
  bool isShowBalance = false;

  List<Wallet> get getWallets => _wallets;

  Wallet get currentWallet => _selectedWallet;

  bool get isLoading => _isLoading;

  String get userId => _userId;

  String? get error => _error;

  Timer? _timer;

  Timer? get timer => _timer;

  void setUserId(String userId) {
    _userId = userId;
  }

  Future<void> loadUserWallets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    var res = await _usecase.getListWallet(_userId);
    if (!res.isSuccess) {
      _error = res.error!.message;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _wallets = res.data!;
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

  void updateBalanceByInterval() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 15), (_) async {
      var res = await _usecase.getListWallet(_userId);
      if (res.isSuccess) {
        _wallets = res.data!;
        if (_wallets.isNotEmpty) {
          _selectedWallet = _wallets[0];
        }
        notifyListeners();
        return;
      }
    });
  }

  void stopAutoUpdate() {
    _timer?.cancel();
  }

  void changeShowBalance() {
    isShowBalance = !isShowBalance;
    notifyListeners();
  }

  void copyAddress(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _selectedWallet.address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Wallet\'s address has been copied to the clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
