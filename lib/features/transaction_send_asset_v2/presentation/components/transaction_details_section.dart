import 'package:flutter/material.dart';

import '../../../../core/helper/helper.dart';

class TransactionDetailsSection extends StatelessWidget {
  final String receiverAddress;
  final String networkFeeInFiat;
  final String networkFeeInAsset;

  const TransactionDetailsSection({
    super.key,
    required this.receiverAddress,
    required this.networkFeeInFiat,
    required this.networkFeeInAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Send To Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Send to', style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  shortenMiddleResponsive(
                    receiverAddress,
                    MediaQuery.of(context).size.width,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Icon(Icons.open_in_new, color: Colors.orange, size: 20),
          ],
        ),

        const SizedBox(height: 20),

        // Transaction Speed Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Transaction Speed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Regular ~ 3-15 min',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const Icon(Icons.edit, color: Colors.orange, size: 20),
          ],
        ),

        const SizedBox(height: 20),

        // Network Fee Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'Network Fee',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.info_outline, color: Colors.orange, size: 16),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Paid to miners',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  networkFeeInFiat,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  networkFeeInAsset,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
} 