import 'package:digital_asset_flutter/component/asset_card.dart';
import 'package:digital_asset_flutter/features/auth/data/source/network/user_datasources.dart';
import 'package:digital_asset_flutter/features/auth/domain/usecases/user_usecase.dart';
import 'package:digital_asset_flutter/features/auth/presentation/provider/user_provider.dart';
import 'package:digital_asset_flutter/features/wallet/data/network/wallet_datasources.dart';
import 'package:digital_asset_flutter/features/wallet/domain/usecases/wallet_usecase.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../transaction/presentation/send_transaction_overview.dart';
import '../../wallet/domain/entities/wallet.dart';
import '../../wallet/presentation/swap.dart';
import '../../wallet/presentation/wallet_selector.dart';

class GeneralInfo extends StatefulWidget {
  GeneralInfo({super.key}) {
    repo = UserRepositoryImpl(http.Client());
    userUsecase = UserUsecases(userRepository: repo);
    walletRepo = WalletRepositoryImpl(http.Client());
    walletUsecase = WallerUsecases(walletRepository: walletRepo);
  }

  late final UserRepositoryImpl repo;
  late final UserUsecases userUsecase;
  late final WalletRepositoryImpl walletRepo;
  late final WallerUsecases walletUsecase;
  int selectedWallet = 0;

  void _showWalletSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => WalletSelectorModal(walletUsecases: walletUsecase),
    );
  }

  void _showSendScreen(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final wallets = await walletUsecase.getUserWallet(userProvider.user!.id);
    if (!wallets.isSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(wallets.error!.toString())));
      return;
    }
    if (wallets.data!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("You have to create wallet first")));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SendCryptoModal(),
    );
  }

  void _showSwapScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SwapScreen(), fullscreenDialog: true),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Icon(icon, color: Colors.black, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? Colors.orange : Colors.grey, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.orange : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  State<StatefulWidget> createState() => _GeneralInfoState();
}

class _GeneralInfoState extends State<GeneralInfo> {
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    Provider.of<WalletProvider>(context, listen: false).updateValuation(widget.walletUsecase);
  }

  double _calculateBalance(List<AssetBalance> assetBalances) {
    double result = 0;
    for (int i = 0; i < assetBalances.length; i++) {
      if (assetBalances[i].balance != '') {
        result += double.parse(assetBalances[i].balance);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final walletWithoutListenChange = Provider.of<WalletProvider>(context, listen: false).wallet;

    List<AssetBalance> assetBalancesNotListenChange =
        walletWithoutListenChange?.assetBalances == null ||
                walletWithoutListenChange!.assetBalances!.isEmpty
            ? [defaultAssetBalance()]
            : walletWithoutListenChange.assetBalances!;

    final walletWithListenChange = Provider.of<WalletProvider>(context, listen: true).wallet;

    List<AssetBalance> assetBalancesListenChange =
        walletWithListenChange?.assetBalances == null ||
                walletWithListenChange!.assetBalances!.isEmpty
            ? [defaultAssetBalance()]
            : walletWithListenChange.assetBalances!;
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        final totalBalance =
            walletProvider.wallet!.assetBalances == null
                ? 0
                : _calculateBalance(walletProvider.wallet!.assetBalances!);
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Essentials',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              // Make Main Wallet clickable
                              GestureDetector(
                                onTap: () async {
                                  widget._showWalletSelector(context);
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      walletProvider.wallet!.walletName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.keyboard_arrow_down, color: Colors.white),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.qr_code_scanner,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
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
                                      widget.userUsecase.signOut();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Security Level
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.security, color: Colors.black, size: 16),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Security Level: 2 of 9',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                'Boost security',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Security Progress Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: LinearProgressIndicator(
                            value: 2 / 9,
                            backgroundColor: Colors.grey[800],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                            minHeight: 4,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // FaceLock Warning
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.brown.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange, size: 20),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Add 3D FaceLock to protect your account',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Balance Section with Background
                        Container(
                          height: 200,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.orange.withOpacity(0.3),
                                Colors.brown.withOpacity(0.5),
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'My Balance',
                                      style: TextStyle(color: Colors.white70, fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          '\$${totalBalance.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(Icons.visibility_off, color: Colors.white70, size: 20),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Action Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              widget._buildActionButton(
                                context,
                                Icons.arrow_upward,
                                'Send',
                                onTap: () => widget._showSendScreen(context),
                              ),
                              widget._buildActionButton(context, Icons.arrow_downward, 'Receive'),
                              widget._buildActionButton(
                                context,
                                Icons.swap_horiz,
                                'Swap',
                                onTap: () => widget._showSwapScreen(context),
                              ),
                              widget._buildActionButton(context, Icons.add, 'Buy'),
                              widget._buildActionButton(context, Icons.menu, 'More'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Zengo Pro Card
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.credit_card, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Buy crypto with up to 50% less fees\nwith Zengo Pro',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Text(
                                          'Try Pro Now',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.orange,
                                          size: 12,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.close, color: Colors.grey, size: 20),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Page Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        ListView.builder(
                          itemCount: assetBalancesListenChange.length,
                          physics: NeverScrollableScrollPhysics(), // disable inner scrolling
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return AssetCard(
                              assetSymbol: assetBalancesListenChange[index].assetSymbol,
                              balance: assetBalancesListenChange[index].balance,
                              assetBalance: weiToEth(assetBalancesListenChange[index].assetBalance),
                              lastChange: assetBalancesListenChange[index].last24hChange,
                            );
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
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
}
