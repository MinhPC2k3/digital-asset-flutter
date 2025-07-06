import 'package:digital_asset_flutter/features/transaction_history_v2/domain/entities/transaction_history.dart';
import 'package:flutter/material.dart';
import 'package:digital_asset_flutter/core/helper/helper.dart';


class TransactionDetailsModal extends StatelessWidget {
  final TransactionHistory transaction;

  const TransactionDetailsModal({
    super.key,
    required this.transaction,
  });

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
            child: isStatus
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

  Widget _buildRowWithLink(String label, String value) {
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
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => launchURL(value),
              child: const Text(
                'View detail',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Transaction Details',
                  style: TextStyle(
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
            _buildDetailRow('Block Height', transaction.blockNumber.toString()),
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
  }
}