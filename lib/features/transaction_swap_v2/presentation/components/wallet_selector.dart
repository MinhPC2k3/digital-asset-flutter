import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WalletSelector extends StatelessWidget {
  final String selectedWalletName;
  final List<Wallet> otherWallets;
  final ValueChanged<String?> onWalletChanged;
  final bool isSmallScreen;
  final Wallet selectedWallet;

  const WalletSelector({
    Key? key,
    required this.selectedWalletName,
    required this.otherWallets,
    required this.onWalletChanged,
    required this.isSmallScreen,
    required this.selectedWallet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2B35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Destination Wallet',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a wallet compatible with ${selectedWallet.networkName} network',
            style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: isSmallScreen ? 13 : 14),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF3A3B45),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedWalletName,
                      onChanged: onWalletChanged,
                      dropdownColor: const Color(0xFF3A3B45),
                      icon: const SizedBox.shrink(),
                      isExpanded: true,
                      items:
                          otherWallets.map<DropdownMenuItem<String>>((Wallet wallet) {
                            return DropdownMenuItem<String>(
                              value:
                                  '${wallet.walletName} - ${wallet.networkName} - ${wallet.address}',
                              child: Text(
                                '${wallet.walletName} - ${wallet.networkName} - ${wallet.address}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 13 : 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: selectedWallet.address));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Address copied to clipboard'),
                        backgroundColor: Color(0xFF10B981),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A4B55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.copy, color: Color(0xFF9CA3AF), size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            children: [
              Text(
                'Selected: ',
                style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: isSmallScreen ? 11 : 12),
              ),
              Text(
                selectedWallet.walletName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 11 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3B45),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${selectedWallet.networkName.toUpperCase()} Network',
                  style: TextStyle(
                    color: const Color(0xFF9CA3AF),
                    fontSize: isSmallScreen ? 9 : 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
