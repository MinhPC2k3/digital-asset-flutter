import 'package:digital_asset_flutter/features/auth/presentation/provider/user_provider.dart';
import 'package:digital_asset_flutter/features/user_v2/presentation/components/homepage/wallet_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/homepage_provider.dart';

class HomepageHeader extends StatelessWidget {
  void _showWalletSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => WalletSelectorModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<UserProvider>();
    return Selector<HomepageProvider, String>(
      selector: (_, provider) => provider.currentWallet.walletName,
      shouldRebuild: (previousWalletName, nextWalletName) {
        if (previousWalletName == '' || nextWalletName == '') return false;
        return previousWalletName != nextWalletName;
      },
      builder: (context, walletName, child) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Essentials', style: TextStyle(color: Colors.grey, fontSize: 16)),
              // Make Main Wallet clickable
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () async {
                      _showWalletSelector(context);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            walletName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.copy, color: Colors.orange, size: 20),
                    ),
                    onTap: () {
                      Provider.of<HomepageProvider>(context,listen: false).copyAddress(context);
                    },
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.logout, color: Colors.orange, size: 20),
                    ),
                    onTap: () async {
                      authProvider.logout(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
