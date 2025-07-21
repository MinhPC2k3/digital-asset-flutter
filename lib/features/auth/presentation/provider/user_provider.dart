import 'package:digital_asset_flutter/features/auth/data/source/network/user_datasources.dart';
import 'package:digital_asset_flutter/features/auth/domain/usecases/user_usecase.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../core/constants/route.dart';
import '../../../../core/network/result.dart';
import '../../../user_v2/presentation/pages/homepage.dart';
import '../../../user_v2/presentation/provider/homepage_provider.dart';
import '../../domain/entities/user.dart' as user_model;
import '../../domain/entities/user.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool isLoading = true;

  late UserRepositoryImpl _userRepo;
  late UserUsecases _userUsecase;

  UserProvider() {
    _userRepo = UserRepositoryImpl(http.Client());
    _userUsecase = UserUsecases(userRepository: _userRepo);
  }

  void _loginSuccess(BuildContext context, Result<user_model.User> user) async {
    setUser(user.data!);
    if (!context.mounted) return;
    if (!context.mounted) return;

    Provider.of<HomepageProvider>(context, listen: false).setUserId(user.data!.id);
    await Provider.of<HomepageProvider>(context, listen: false).loadUserWallets();
    changeLoadingStatus(false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomeRefactoredPage()),
      // MaterialPageRoute(builder: (context) => MyHomePage()),
      // MaterialPageRoute(
      //   builder:
      //       (context) =>
      //           UsernameScreen(user: user),
      // ),
    );
  }

  Future<void> userLogin(BuildContext context) async {
    String tokenId = await _userUsecase.signInWithGoogle();
    print("Doing login with google");
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
      print("Doing login success");
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
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomeRefactoredPage()));
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

  void logout(BuildContext context) async {
    await _userUsecase.signOut();
    CustomRouter.navigateTo(context, Routes.auth);
  }

  Future<void> alreadyLogin(BuildContext context) async {
    changeLoadingStatus(true);
    var previousUser = await _userUsecase.getAlreadyLogin();
    if (previousUser != null) {
      print("Doing login success with already login user");
      _loginSuccess(context, Result.success(previousUser));
      return;
    }
    changeLoadingStatus(false);
  }
}
