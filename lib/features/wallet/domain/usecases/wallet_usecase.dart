import 'dart:convert';
import 'dart:typed_data';

import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/dart_ffi.dart';
import 'package:digital_asset_flutter/features/auth/domain/entities/user.dart';
import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';
import 'package:digital_asset_flutter/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:uuid/uuid.dart';

class WallerUsecases {
  WallerUsecases({required WalletRepository walletRepository})
    : _walletRepository = walletRepository;
  final WalletRepository _walletRepository;

  Future<Result<List<Wallet>>> getUserWallet(String userId) async {
    Result<List<Wallet>> listWallet = await _walletRepository.getUserWallet(
      userId,
    );
    return listWallet;
  }

  Future<Result<Wallet>> createWallet(
    String userId,
    String walletName,
    String network,
    String walletPin,
  ) async {
    print("Doing...");
    Result<Wallet> wallet = await _walletRepository.createWallet(
      Wallet(
        id: '',
        walletId: '',
        userId: userId,
        networkId: '',
        networkName: network,
        networkSymbol: '',
        address: '',
        publicKey: '',
        createdAt: null,
        updatedAt: null,
        status: '',
        accountKey: '',
        version: '',
        walletName: walletName,
      ),
    );

    if (!wallet.isSuccess) {
      print("Shared key error: ${wallet.error!.message}");
      return wallet;
    }
    print("Key: ${wallet.data!.accountKey}");
    print("Object ${wallet.data!.networkName}, id: ${wallet.data!.networkId}");
    String result = await GoBridge.computeShareKey(
      Uuid().v4(),
      wallet.data!.accountKey,
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

    Result<Wallet> sharedKeyWallet = await _walletRepository.shareKey(
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

Uint8List bigIntToBytes(BigInt number) {
  // Get bytes in big-endian order
  final bytes = number
      .toRadixString(16)
      .padLeft(64, '0'); // pad for full 32 bytes
  final byteList = <int>[];

  for (var i = 0; i < bytes.length; i += 2) {
    byteList.add(int.parse(bytes.substring(i, i + 2), radix: 16));
  }

  return Uint8List.fromList(byteList);
}
