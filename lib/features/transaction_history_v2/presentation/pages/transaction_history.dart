import 'package:digital_asset_flutter/features/transaction_history_v2/presentation/components/transaction_table.dart';
import 'package:digital_asset_flutter/features/transaction_history_v2/presentation/providers/transaction_history_provider.dart';
import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      final transactionHistoryProvider = Provider.of<TransactionHistoryProvider>(
        context,
        listen: false,
      );
      transactionHistoryProvider.loadTransactionHistory(walletProvider.wallet!.address);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B23),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1A1B23),
        title: const Text(
          'History',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Consumer<TransactionHistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text(provider.error!, style: const TextStyle(color: Colors.white)),
            );
          }

          if (provider.transactionHistory != null) {
            return TransactionTable(transactions: provider.transactionHistory!);
          }

          return const Center(
            child: Text('No transactions found', style: TextStyle(color: Colors.white)),
          );
        },
      ),
    );
  }
}
