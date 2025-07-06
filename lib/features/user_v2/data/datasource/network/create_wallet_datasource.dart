import 'dart:convert';

import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/user_v2/data/datasource/network/mock.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/repositories/create_wallet_repository.dart';
import 'package:http/http.dart' as http;

import '../../models/wallet_dto.dart';

class CreateWalletRepositoryImpl implements CreateWalletRepository {
  final http.Client client;

  CreateWalletRepositoryImpl({required this.client});

  @override
  Future<Result<Wallet>> createWallet() async {
    await Future.delayed(Duration(seconds: 2));
    var res = json.decode(createdWalletResponse);
    var walletData = res['wallet'];

    final wallet = WalletDTO.fromJson(walletData).toEntity();

    return Result.success(wallet);
  }
}
