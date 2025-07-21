import 'package:digital_asset_flutter/features/transaction_send_asset_v2/domain/entities/transaction.dart';

class RawTransactionDTO {
  String fromAddress;
  String toAddress;
  String chainId;
  Map<String, dynamic>? ethereumTx;
  String message;
  String code;

  RawTransactionDTO({
    required this.message,
    required this.ethereumTx,
    required this.toAddress,
    required this.fromAddress,
    required this.code,
    required this.chainId,
  });

  factory RawTransactionDTO.fromJson(Map<String, dynamic> json) {
    var data = json['data'] ?? '';
    var rawTx = data == '' ? '' : data['rawTransaction'];
    var state = json['state'];
    return RawTransactionDTO(
      message: state['message'],
      fromAddress: rawTx == '' ? '' : rawTx['fromAddress'],
      toAddress: rawTx == '' ? '' : rawTx['toAddress'],
      chainId: rawTx == '' ? '' : rawTx['chainId'],
      ethereumTx: rawTx == '' ? null : rawTx['ethereumTx'],
      code: state['code'] ?? '',
    );
  }

  Transaction toDomain(Transaction transaction) {
    print("From address object ${ethereumTx}");
    transaction.rawEthereumTransaction.fromAddress = fromAddress;
    transaction.rawEthereumTransaction.chainId = chainId;
    transaction.rawEthereumTransaction.toAddress = toAddress;
    transaction.rawEthereumTransaction.ethereumTx = ethereumTx!;

    return transaction;
  }
}

class SignatureDTO {
  String s1;
  String sessionID;
  String r;
  String s;
  String v;

  SignatureDTO({
    required this.s1,
    required this.sessionID,
    required this.r,
    required this.s,
    required this.v,
  });

  factory SignatureDTO.fromJson(Map<String, dynamic> json) {
    var signContextData = json['signature'];
    return SignatureDTO(
      s1: json['s1'] ?? '',
      sessionID: json['session_id'] ?? '',
      r: signContextData['r'],
      s: signContextData['s'],
      v: signContextData['v'],
    );
  }

  Signature toDomain() {
    return Signature(r: r, s: s, v: v);
  }
}