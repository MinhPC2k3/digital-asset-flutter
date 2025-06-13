import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';

class Wallet {
  final String id; // UUID
  final String walletId; // UUID
  final String userId; // User email
  final String networkId; // UUID
  final String networkName; // e.g. Ethereum, Bitcoin
  final String networkSymbol; // e.g. ETH, BTC
  final String address; // Wallet address (from public key)
  final String publicKey; // Public key
  final DateTime? createdAt; // Wallet creation time
  final DateTime? updatedAt; // Last update time
  final String status; // Wallet status
  final String accountKey; // Key used for share key phase
  final String version; // Version of account key
  final String walletName; // User-given name for the wallet

  const Wallet({
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
