import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';

class Wallet {
   String id; // UUID
   String walletId; // UUID
   String userId; // User email
   String networkId; // UUID
   String networkName; // e.g. Ethereum, Bitcoin
   String networkSymbol; // e.g. ETH, BTC
   String address; // Wallet address (from public key)
   String publicKey; // Public key
   DateTime? createdAt; // Wallet creation time
   DateTime? updatedAt; // Last update time
   String status; // Wallet status
   String accountKey; // Key used for share key phase
   String version; // Version of account key
   String walletName; // User-given name for the wallet

  Wallet({
    required this.id,
    required this.walletId,
    required this.userId,
    required this.networkId,
    required this.networkName,
    required this.networkSymbol,
    required this.address,
    required this.publicKey,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.accountKey,
    required this.version,
    required this.walletName,
  });
}

class ShareKeyData {
  final String id;
  final String p10;
  final String p12;
  final String p21;

  ShareKeyData({
    required this.id,
    required this.p10,
    required this.p12,
    required this.p21,
  });

  factory ShareKeyData.fromJson(Map<String, dynamic> json) {
    return ShareKeyData(
      id: json['id'],
      p10: json['p10'],
      p12: json['p12'],
      p21: json['p21'],
    );
  }

  static Uint8List _bigIntToBytes(BigInt number) {
    final hexStr = number.toRadixString(16);
    final evenLengthHex = hexStr.length.isOdd ? '0$hexStr' : hexStr;
    return Uint8List.fromList(hex.decode(evenLengthHex));
  }
}

class WalletProvider with ChangeNotifier{
  Wallet? _wallet;

  Wallet? get wallet => _wallet;

  void setWallet(Wallet wallet) {
    _wallet = wallet;
    notifyListeners();
  }
}