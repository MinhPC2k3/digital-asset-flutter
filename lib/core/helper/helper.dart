import 'package:digital_asset_flutter/features/transaction/domain/entities/transaction.dart';
import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';
import 'package:provider/provider.dart';

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

String cleanDecimal(double value) {
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
      tx.transactionType = TransactionType.TX_TYPE_ERC20_TRANSFER;
      break;
  }
  return tx;
}
