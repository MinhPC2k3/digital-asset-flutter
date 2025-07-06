import 'dart:math';
import 'dart:typed_data';

import 'package:digital_asset_flutter/features/transaction/domain/entities/transaction.dart';
import 'package:digital_asset_flutter/features/transaction_send_asset_v2/domain/entities/transaction.dart'
    as transaction_v2;
import 'package:url_launcher/url_launcher.dart';

import '../../features/transaction/domain/usecases/transaction_usecases.dart';

String shortenMiddleResponsive(String text, double screenWidth) {
  // Adjust these thresholds as needed
  int head, tail;

  if (screenWidth < 300) {
    head = 3;
    tail = 2;
  } else if (screenWidth < 500) {
    head = 6;
    tail = 4;
  } else {
    head = 10;
    tail = 6;
  }

  if (text.length <= head + tail + 3) return text;
  return '${text.substring(0, head)}...${text.substring(text.length - tail)}';
}

BigInt covertStringToBigInt(String hexString) {
  if (hexString.startsWith("0x")) {
    hexString = hexString.substring(2);
  }

  BigInt value = BigInt.parse(hexString, radix: 16);
  return value;
}

String cleanFloatDecimal(double value) {
  String fixed = value.toStringAsFixed(6);
  return fixed.replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
}

Transaction addTransactionType(Transaction tx) {
  switch (tx.assetId) {
    case 'asset-eth-0001':
      tx.blockchainType = BlockchainType.BLOCKCHAIN_TYPE_ETHEREUM;
      tx.transactionType = TransactionType.TX_TYPE_NATIVE_TRANSFER;
      tx.amount = ethToWeiString(tx.amount);
      break;
    case 'asset-datnt14-token-0001':
      tx.blockchainType = BlockchainType.BLOCKCHAIN_TYPE_ETHEREUM;
      tx.transactionType = TransactionType.TX_TYPE_ERC20_TRANSFER;
      break;
    case 'blc-token-0001':
      tx.blockchainType = BlockchainType.BLOCKCHAIN_TYPE_ETHEREUM;
      tx.transactionType = TransactionType.TX_TYPE_ERC20_TRANSFER;
      tx.amount = ethToWeiString(tx.amount);
      break;
    case 'asset-nft-token-lcp-0001':
      tx.blockchainType = BlockchainType.BLOCKCHAIN_TYPE_ETHEREUM;
      tx.transactionType = TransactionType.TX_TYPE_ERC721_TRANSFER;
      break;
  }
  return tx;
}

transaction_v2.Transaction addTransactionTypeV2(transaction_v2.Transaction tx) {
  switch (tx.assetId) {
    case 'asset-eth-0001':
      tx.blockchainType = transaction_v2.BlockchainType.BLOCKCHAIN_TYPE_ETHEREUM;
      tx.transactionType = transaction_v2.TransactionType.TX_TYPE_NATIVE_TRANSFER;
      tx.amount = ethToWeiString(tx.amount);
      break;
    case 'asset-datnt14-token-0001':
      tx.blockchainType = transaction_v2.BlockchainType.BLOCKCHAIN_TYPE_ETHEREUM;
      tx.transactionType = transaction_v2.TransactionType.TX_TYPE_ERC20_TRANSFER;
      break;
    case 'blc-token-0001':
      tx.blockchainType = transaction_v2.BlockchainType.BLOCKCHAIN_TYPE_ETHEREUM;
      tx.transactionType = transaction_v2.TransactionType.TX_TYPE_ERC20_TRANSFER;
      tx.amount = ethToWeiString(tx.amount);
      break;
    case 'asset-nft-token-lcp-0001':
      tx.blockchainType = transaction_v2.BlockchainType.BLOCKCHAIN_TYPE_ETHEREUM;
      tx.transactionType = transaction_v2.TransactionType.TX_TYPE_ERC721_TRANSFER;
      break;
  }
  return tx;
}

String getTimeAgo(DateTime countAt) {
  final now = DateTime.now();
  final diff = now.difference(countAt);

  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

DateTime timeUnixToDatetime(int timeUnix) {
  return DateTime.fromMillisecondsSinceEpoch(timeUnix * 1000);
}

double convertWithDecimal(double value, int decimal) {
  return value / pow(10, decimal);
}

launchURL(String urlStr) async {
  final Uri _url = Uri.parse(urlStr);
  if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $_url');
  }
}

/// Converts a base-10 BigInt string to a byte array (Uint8List)
Uint8List bigIntStringToBytes(String value) {
  final bigInt = BigInt.parse(value, radix: 10);

  final bytes = _encodeBigInt(bigInt);
  return Uint8List.fromList(bytes);
}

/// Helper: Converts BigInt to bytes (unsigned big-endian)
List<int> _encodeBigInt(BigInt number) {
  if (number == BigInt.zero) return [0];

  final result = <int>[];
  var temp = number;

  while (temp > BigInt.zero) {
    result.insert(0, (temp & BigInt.from(0xff)).toInt());
    temp = temp >> 8;
  }

  return result;
}

String toEthereumHex(BigInt bigInt) {
  // Convert BigInt to hexadecimal string
  String hex = bigInt.toRadixString(16);

  // Remove any leading zeros (not necessary here, but good practice)
  hex = hex.replaceFirst(RegExp(r'^0+'), '');

  // Ensure at least '0' is present
  if (hex.isEmpty) {
    hex = '0';
  }

  // Add '0x' prefix
  return '0x$hex';
}

BigInt bytesToBigInt(Uint8List bytes) {
  BigInt result = BigInt.zero;
  for (var byte in bytes) {
    result = (result << 8) | BigInt.from(byte);
  }
  return result;
}

String convertToAmountForApi(double value, int decimal) {
  return (value * pow(10, decimal)).toString();
}
