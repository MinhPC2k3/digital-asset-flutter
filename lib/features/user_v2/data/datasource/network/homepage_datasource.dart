import 'dart:convert';

import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/user_v2/data/datasource/network/mock.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';
import 'package:http/http.dart' as http;

import '../../../domain/repositories/homepage_repository.dart';
import '../../models/wallet_dto.dart';

class HomepageRepositoriesImpl implements HomepageRepository {
  final http.Client client;

  HomepageRepositoriesImpl({required this.client});

  @override
  Future<Result<List<Wallet>>> getWallets() async {
    await Future.delayed(Duration(seconds: 2));
    var res = json.decode(homepageResponse);
    var walletData = res['wallets'] as List<dynamic>;

    final wallets = walletData.map((wallet) => WalletDTO.fromJson(wallet).toEntity()).toList();

    return Result.success(wallets);
  }
}
