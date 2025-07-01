import 'package:digital_asset_flutter/core/helper/helper.dart';
import 'package:digital_asset_flutter/features/auth/presentation/provider/user_provider.dart';
import 'package:digital_asset_flutter/features/transaction/presentation/provider/transaction_provider.dart';
import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';
import 'package:digital_asset_flutter/features/wallet/domain/usecases/wallet_usecase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/result.dart';
import '../domain/entities/transaction.dart';

class TransactionHistory extends StatelessWidget {
  const TransactionHistory({super.key});

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
      body: const TransactionTable(),
    );
  }
}

class TransactionTable extends StatefulWidget {
  const TransactionTable({super.key});

  @override
  TransactionTableState createState() => TransactionTableState();
}

class TransactionTableState extends State<TransactionTable> {
  void _showTransactionModal(BuildContext context, TransactionHistoryData transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF2A2B35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction Details',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Token', transaction.tokenSymbol, isToken: true),
                _buildDetailRow('Amount', cleanFloatDecimal(transaction.value)),
                _buildDetailRow('Date', transaction.timestamp.toString()),
                _buildDetailRow('Time Ago', transaction.timeAgo),
                _buildDetailRow('Direction', transaction.direction),
                _buildDetailRow('Status', transaction.status, isStatus: true),
                _buildDetailRow('Fee', cleanFloatDecimal(transaction.fee)),
                _buildDetailRow('Block Height', transaction.blockNumber),
                _buildRowWithLink('Explorer Link', transaction.explorerUrl),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isToken = false,
    bool isStatus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
          ),
          Expanded(
            child:
                isStatus
                    ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    : Text(
                      value,
                      style: TextStyle(
                        color: isToken ? const Color(0xFF10B981) : Colors.white,
                        fontSize: 14,
                        fontWeight: isToken ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowWithLink(
    String label,
    String value, {
    bool isToken = false,
    bool isStatus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero, // Removes default padding
                minimumSize: Size(0, 0), // Optional: avoid min constraints
                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrinks hit area
              ),
              onPressed: () => launchURL(value),
              child: Text('View detail',style: TextStyle(
                decoration: TextDecoration.underline, // Adds underline
                color: Colors.blue, // Optional: change text color
              ),),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
    bool showAll = screenWidth > 500;
    bool showMedium = screenWidth > 300;
    return FutureBuilder<Result<List<TransactionHistoryData>>>(
      future: txProvider.loadTransactionHistory(walletProvider.wallet!.address),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // While loading
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          if (!snapshot.data!.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(snapshot.data!.error!.message), backgroundColor: Colors.red),
            );
            return Text('Error: ${snapshot.data!.error!.message}');
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: DataTable(
                  showCheckboxColumn: false,
                  columnSpacing: 20,
                  dataRowMaxHeight: 80,
                  headingRowColor: MaterialStateProperty.all(const Color(0xFF2A2B35)),
                  dataRowColor: MaterialStateProperty.resolveWith<Color?>((
                    Set<MaterialState> states,
                  ) {
                    return const Color(0xFF1A1B23);
                  }),
                  headingTextStyle: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  dataTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
                  columns: [
                    if (showMedium) DataColumn(label: Text('Token')),
                    if (showMedium) DataColumn(label: Text('Amount')),
                    if (showAll) DataColumn(label: Text('Date')),
                    if (showAll) DataColumn(label: Text('Direction')),
                    if (showMedium) DataColumn(label: Text('Status')),
                    if (showAll) DataColumn(label: Text('')),
                  ],
                  rows:
                      snapshot.data!.data!.map((transaction) {
                        return DataRow(
                          onSelectChanged: (selected) {
                            if (selected == true) {
                              _showTransactionModal(context, transaction);
                            }
                          },
                          cells: [
                            if (showMedium)
                              DataCell(
                                Text(
                                  transaction.tokenSymbol,
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (showMedium) DataCell(Text(cleanFloatDecimal(transaction.value))),
                            if (showAll)
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [Text(transaction.timestamp.toString())],
                                ),
                              ),
                            if (showAll) DataCell(Text(transaction.direction)),
                            if (showMedium)
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    transaction.status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            if (showAll)
                              const DataCell(Icon(Icons.chevron_right, color: Color(0xFF9CA3AF))),
                          ],
                        );
                      }).toList(),
                ),
              ),
            );
          }
        }
      },
    );
  }
}
