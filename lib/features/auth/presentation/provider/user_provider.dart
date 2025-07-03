import 'package:digital_asset_flutter/features/auth/data/source/network/user_datasources.dart';
import 'package:digital_asset_flutter/features/auth/domain/usecases/user_usecase.dart';
import 'package:digital_asset_flutter/features/auth/presentation/homepage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../core/network/result.dart';
import '../../../asset/data/source/network/asset_datasource.dart';
import '../../../asset/domain/entities/entities.dart';
import '../../../wallet/data/network/wallet_datasources.dart';
import '../../../wallet/domain/entities/wallet.dart';
import '../../../wallet/domain/usecases/wallet_usecase.dart';
import '../../domain/entities/user.dart' as user_model;
import '../../domain/entities/user.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool isLoading = false;

  late UserRepositoryImpl _userRepo;
  late UserUsecases _userUsecase;
  late WalletRepositoryImpl _walletRepo;
  late WalletUsecases _walletUsecase;

  UserProvider() {
    _userRepo = UserRepositoryImpl(http.Client());
    _userUsecase = UserUsecases(userRepository: _userRepo);
    _walletRepo = WalletRepositoryImpl(http.Client());
    _walletUsecase = WalletUsecases(walletRepository: _walletRepo);
  }

  Future<Result<List<Wallet>>> getWallet(String userID) async {
    Result<List<Wallet>> listWallets = await _walletUsecase.getUserWallet(userID);
    return listWallets;
  }

  void _loginSuccess(BuildContext context, Result<user_model.User> user) async {
    setUser(user.data!);
    var listWallets = await getWallet(user.data!.id);
    print("Number of user 's wallet: ${listWallets.data!.length}");
    for (int i = 0; i < listWallets.data!.length; i++) {
      print("Wallet network ${listWallets.data![i].networkName}");
    }
    if (!context.mounted) return;
    var userWallet = listWallets.data!.isEmpty ? null : listWallets.data![0];
    if (userWallet != null) {
      Provider.of<WalletProvider>(context, listen: false).setWallet(userWallet);
      Provider.of<WalletProvider>(context, listen: false).setListWallets(listWallets.data!);
      await _walletUsecase.getWalletAssetBalances(userWallet);
    }
    if (!context.mounted) return;
    changeLoadingStatus(false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
      // MaterialPageRoute(
      //   builder:
      //       (context) =>
      //           UsernameScreen(user: user),
      // ),
    );

    var assetRepo = AssetRepositoriesImpl();
    var assetInfoMap = await assetRepo.getListAssetByNetwork('ethereum');
    Provider.of<AssetProvider>(context, listen: false).setAssetInfo(assetInfoMap!);
    var listAsset = await assetRepo.getListAssets();
    if (listAsset.isSuccess) {
      Provider.of<AssetProvider>(context, listen: false).setListAssetInfo(listAsset.data!);
    }
  }

  Future<void> userLogin(BuildContext context) async {
    String tokenId = await _userUsecase.signInWithGoogle();
    if (tokenId == "") {
      print("Error google here");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("login with Google error")));
    }
    changeLoadingStatus(true);
    Result<user_model.User> user = await _userUsecase.login(tokenId);
    if (!context.mounted) return;
    if (user.isSuccess) {
      _loginSuccess(context, user);
    } else {
      changeLoadingStatus(false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(user.error!.toString())));
    }
  }

  Future<void> userRegister(BuildContext context) async {
    isLoading = true;
    Result<user_model.User> user = await _userUsecase.register();
    if (!context.mounted) return;
    if (user.isSuccess) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(user.error!.toString())));
    }
    isLoading = false;
  }

  void changeLoadingStatus(bool status) {
    isLoading = status;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}
