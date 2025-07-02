import 'dart:math';

import 'package:digital_asset_flutter/features/transaction/domain/entities/transaction.dart';
import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/auth/domain/entities/user.dart';
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
