import 'package:digital_asset_flutter/features/transaction_history_v2/domain/entities/transaction_history.dart';
import 'package:digital_asset_flutter/features/transaction_history_v2/presentation/components/transaction_detail_modal.dart';
import 'package:flutter/material.dart';
import 'package:digital_asset_flutter/core/helper/helper.dart';

class TransactionTable extends StatelessWidget {
  final List<TransactionHistory> transactions;

  const TransactionTable({super.key, required this.transactions});

  void _showTransactionModal(BuildContext context, TransactionHistory transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) => TransactionDetailsModal(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool showAll = screenWidth > 500;
    bool showMedium = screenWidth > 300;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DataTable(
          showCheckboxColumn: false,
          columnSpacing: 20,
          dataRowMaxHeight: 80,
          headingRowColor: MaterialStateProperty.all(const Color(0xFF2A2B35)),
          dataRowColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) => const Color(0xFF1A1B23),
          ),
          headingTextStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          dataTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
          columns: [
            if (showMedium) const DataColumn(label: Text('Token')),
            if (showMedium) const DataColumn(label: Text('Amount')),
            if (showAll) const DataColumn(label: Text('Date')),
            if (showAll) const DataColumn(label: Text('Direction')),
            if (showMedium) const DataColumn(label: Text('Status')),
            if (showAll) const DataColumn(label: Text('')),
          ],
          rows:
              transactions.map((transaction) {
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
