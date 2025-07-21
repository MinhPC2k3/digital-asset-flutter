import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_send_asset_provider.dart';

class AddressInput extends StatelessWidget {
  const AddressInput({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionSendAssetProvider>(context, listen: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipient Address',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: provider.isValidAddress ? const Color(0xFFFF6B35) : Colors.transparent,
              width: 1,
            ),
          ),
          child: TextField(
            controller: provider.addressController,
            onChanged: provider.validateAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '0x... or ENS name',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),

        if (provider.isValidAddress)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text('Valid Ethereum address', style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ),
      ],
    );
  }
}
