import 'package:digital_asset_flutter/core/helper/helper.dart';

enum TransactionType {
  TX_TYPE_NATIVE_TRANSFER,
  TX_TYPE_ERC20_TRANSFER,
  TX_TYPE_ERC20_APPROVE,
  TX_TYPE_ERC721_TRANSFER,
}

enum BlockchainType { BLOCKCHAIN_TYPE_ETHEREUM }

enum CurveType { CURVE_SECP256K1 }

class Transaction {
  String userId;
  String walletId;
  String assetId;
  String amount;
  String receiverAddress;
  BlockchainType? blockchainType;
  String networkName;
  Map<String, dynamic>? metadata;
  RawEthereumTransaction rawEthereumTransaction;
  TransactionType? transactionType;
  String tokenId;

  Transaction({
    required this.userId,
    required this.walletId,
    required this.assetId,
    required this.amount,
    required this.receiverAddress,
    required this.blockchainType,
    required this.networkName,
    required this.transactionType,
    required this.tokenId,
  }) : rawEthereumTransaction = RawEthereumTransaction(
         blockchainType: BlockchainType.BLOCKCHAIN_TYPE_ETHEREUM,
         networkName: '',
         fromAddress: '',
         toAddress: '',
         chainId: '',
         txHash: '',
         ethereumTx: {},
       );

  @override
  String toString() {
    return 'Transaction('
        'userId: $userId, '
        'walletId: $walletId, '
        'assetId: $assetId, '
        'amount: $amount, '
        'receiverAddress: $receiverAddress, '
        'blockchainType: $blockchainType, '
        'networkName: $networkName, '
        'metadata: ${metadata != null ? metadata.toString() : 'null'}, '
        'rawEthereumTransaction: ${rawEthereumTransaction.toString()}, '
        'transactionType: $transactionType'
        ')';
  }
}

class RawEthereumTransaction {
  BlockchainType blockchainType;
  String networkName;
  String fromAddress;
  String toAddress;
  String chainId;
  String txHash;
  Map<String, dynamic> ethereumTx;

  RawEthereumTransaction({
    required this.blockchainType,
    required this.networkName,
    required this.fromAddress,
    required this.toAddress,
    required this.chainId,
    required this.txHash,
    required this.ethereumTx,
  });

  @override
  String toString() {
    return 'RawEthereumTransaction(blockchainType: $blockchainType, networkName: $networkName, from: $fromAddress, to: $toAddress, chainId: $chainId, txHash: $txHash, ethereumTx: $ethereumTx)';
  }
}

class SignInfo {
  String k1;
  String gamma1;
  String msgFingerprint;
  String delta1;
  String w1;
  String k2;
  String sum;
  String sessionId;
  String sessionIdOnline;
  Gamma1G? gamma1g;
  String s1;

  SignInfo({
    required this.k1,
    required this.gamma1,
    required this.msgFingerprint,
    required this.delta1,
    required this.w1,
    required this.k2,
    required this.gamma1g,
    required this.sessionId,
    required this.sum,
    required this.sessionIdOnline,
    required this.s1,
  });

  factory SignInfo.fromJson(Map<String, dynamic> json) {
    var gamma1gJson = json['gamma1g'];
    return SignInfo(
      k1: json['k1'] ?? '',
      gamma1: json['gamma1'] ?? '',
      msgFingerprint: json['message_fingerprint'] ?? '',
      delta1: json['delta1'] ?? '',
      w1: json['w1'] ?? '',
      k2: json['k2'] ?? '',
      sessionId: json['sessionId'] ?? '',
      sum: json['sum'] ?? '',
      sessionIdOnline: '',
      s1: json['s1'] ?? '',
      // gamma1g: null,
      gamma1g:
          gamma1gJson == null
              ? null
              : Gamma1G(x: gamma1gJson['x'], y: gamma1gJson['y'], curve: gamma1gJson['curve']),
    );
  }
}

class Gamma1G {
  String x;
  String y;
  String curve;

  Gamma1G({required this.x, required this.y, required this.curve});
}

class Signature {
  String r;
  String s;
  String v;

  Signature({required this.r, required this.s, required this.v});
}

class TransactionHistoryData {
  final String txHash;
  final String blockNumber;
  final String from;
  final String to;
  double value;
  final String tokenType;
  final String tokenSymbol;
  double fee;
  final String status;
  final DateTime? timestamp;
  final String direction;
  final String explorerUrl;
  final int tokenDecimal;
  String timeAgo;

  TransactionHistoryData({
    required this.txHash,
    required this.blockNumber,
    required this.from,
    required this.to,
    required this.value,
    required this.tokenType,
    required this.tokenSymbol,
    required this.fee,
    required this.status,
    required this.timestamp,
    required this.direction,
    required this.explorerUrl,
    required this.tokenDecimal,
    required this.timeAgo,
  });

  factory TransactionHistoryData.fromJson(Map<String, dynamic> json) {
    print("Doing parse json");
    return TransactionHistoryData(
      txHash: json['txHash'] ?? '',
      blockNumber: json['blockNumber'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      value: double.tryParse(json['value']?.toString() ?? '0') ?? 0,
      tokenType: json['tokenType'] ?? '',
      tokenSymbol: json['tokenSymbol'] ?? '',
      fee: double.tryParse(json['fee']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? '',
      timestamp:
          json['timestamp'] != null
              ? timeUnixToDatetime(int.tryParse(json['timestamp'].toString()) ?? 0)
              : null,
      direction: json['direction'] ?? '',
      explorerUrl: json['explorerUrl'] ?? '',
      tokenDecimal: json['tokenDecimal'] ?? 0,
      timeAgo: "",
    );
  }

  // factory TransactionHistoryData.fromJson(Map<String, dynamic> json) {
  //   print("Doing parse json");
  //   return TransactionHistoryData(
  //     txHash: json['txHash'] ?? '',
  //     blockNumber: json['blockNumber'] ?? '',
  //     from: json['from'] ?? '',
  //     to: json['to'] ?? '',
  //     value: double.parse(json['value']),
  //     tokenType: json['tokenType'] ?? '',
  //     tokenSymbol: json['tokenSymbol'] ?? '',
  //     fee: double.parse(json['fee']),
  //     status: json['status'] ?? '',
  //     timestamp: json['timestamp'] != null ? timeUnixToDatetime(json['timestamp']) : null,
  //     direction: json['direction'] ?? '',
  //     explorerUrl: json['explorerUrl'] ?? '',
  //     tokenDecimal: json['tokenDecimal'] ?? 0,
  //     timeAgo: "",
  //   );
  // }
}
