import 'package:flutter/material.dart';

class SendAssetHeader extends StatelessWidget {
  final String walletName;
  final VoidCallback onClose;

  const SendAssetHeader({
    super.key,
    required this.walletName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[600],
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, color: Colors.orange, size: 24),
              ),
              Column(
                children: [
                  const Text(
                    'Send',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    walletName,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              // Empty container to balance the layout
              const SizedBox(width: 24),
            ],
          ),
        ),
      ],
    );
  }
} 