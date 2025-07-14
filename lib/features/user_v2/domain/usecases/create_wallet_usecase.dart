import 'package:digital_asset_flutter/core/helper/helper.dart';
import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/repositories/create_wallet_repository.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import 'dart:convert';


import '../../../../core/helper/dart_ffi.dart';

class CreateWalletUsecase {
  final CreateWalletRepository repository;

  CreateWalletUsecase({required this.repository});

  Future<Result<Wallet>> createWallet(
    String userId,
    String walletName,
    String network,
    String walletPin,
  ) async {
    Result<Wallet> wallet = await repository.createWallet(
      Wallet(
        walletId: '',
        userId: userId,
        networkName: network,
        address: '',
        version: '',
        walletKey: '',
        assets: [],
        nfts: [],
        totalValue: 0,
        walletName: walletName,
      ),
    );

    if (!wallet.isSuccess) {
      print("Shared key error: ${wallet.error!.message}");
      return wallet;
    }
    print("Key: ${wallet.data!.walletKey}");
    print("Object ${wallet.data!.networkName}");
    String result = await GoBridge.computeShareKey(
      Uuid().v4(),
      wallet.data!.walletKey,
      Uint8List.fromList(utf8.encode(walletPin)),
    );
    print("Shared key data: $result");
    ShareKeyData shareKeyData = ShareKeyData.fromJson(jsonDecode(result));

    BigInt p10BigInt = BigInt.parse(shareKeyData.p10);
    Uint8List p10 = bigIntToBytes(p10BigInt);

    BigInt p12BigInt = BigInt.parse(shareKeyData.p12);
    Uint8List p12 = bigIntToBytes(p12BigInt);

    BigInt p21BigInt = BigInt.parse(shareKeyData.p21);
    Uint8List p21 = bigIntToBytes(p21BigInt);

    Result<Wallet> sharedKeyWallet = await repository.shareKey(
      wallet.data!,
      base64Encode(p10),
      base64Encode(p12),
      base64Encode(p21),
    );

    if (!sharedKeyWallet.isSuccess) {
      print("Shared key error: ${sharedKeyWallet.error!.message}");
      return sharedKeyWallet;
    }

    return wallet;
  }
}
