class TransactionHistory {
  String txHash;
  int blockNumber;
  String fromAddress;
  String toAddress;
  double value;
  String tokenType;
  String tokenSymbol;
  double fee;
  String status;
  String direction;
  String explorerUrl;
  DateTime timestamp;
  String timeAgo;

  TransactionHistory({
    required this.txHash,
    required this.blockNumber,
    required this.fromAddress,
    required this.toAddress,
    required this.value,
    required this.tokenType,
    required this.tokenSymbol,
    required this.fee,
    required this.status,
    required this.direction,
    required this.explorerUrl,
    required this.timestamp,
    required this.timeAgo,
  });
}
