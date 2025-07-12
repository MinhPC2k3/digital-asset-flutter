import 'dart:async';

import 'package:digital_asset_flutter/component/asset_card.dart';
import 'package:digital_asset_flutter/features/auth/data/source/network/user_datasources.dart';
import 'package:digital_asset_flutter/features/auth/domain/usecases/user_usecase.dart';
import 'package:digital_asset_flutter/features/auth/presentation/provider/user_provider.dart';
import 'package:digital_asset_flutter/features/wallet/data/network/wallet_datasources.dart';
import 'package:digital_asset_flutter/features/wallet/domain/usecases/wallet_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../core/constants/route.dart';
import '../../transaction/presentation/send_transaction_overview.dart';
import '../../wallet/domain/entities/wallet.dart';
import '../../transaction/presentation/transaction_swap.dart';
import '../../wallet/presentation/wallet_selector.dart';

class GeneralInfo extends StatefulWidget {
  GeneralInfo({super.key}) {
    repo = UserRepositoryImpl(http.Client());
    userUsecase = UserUsecases(userRepository: repo);
    walletRepo = WalletRepositoryImpl(http.Client());
    walletUsecase = WalletUsecases(walletRepository: walletRepo);
  }

  late final UserRepositoryImpl repo;
  late final UserUsecases userUsecase;
  late final WalletRepositoryImpl walletRepo;
  late final WalletUsecases walletUsecase;
  int selectedWallet = 0;
  bool isShowBalance = false;

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
    var listWallets = Provider.of<WalletProvider>(context, listen: false).listWallet;
    if (listWallets.length < 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("You have to create other wallet first")));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SimpleSwapInterface(
              userWallets: listWallets,
              currentWallet: Provider.of<WalletProvider>(context).wallet!,
            ),
        fullscreenDialog: true,
      ),
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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (_) async {
      Provider.of<WalletProvider>(context, listen: false).updateValuation(widget.walletUsecase);
    });
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
  void dispose() {
    _timer?.cancel(); // Don't forget to cancel the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WalletProvider>(context);
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
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: GestureDetector(
                                    onTap: () async {
                                      widget._showWalletSelector(context);
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            walletProvider.wallet!.walletName,
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
                                      Clipboard.setData(
                                        ClipboardData(text: walletProvider.wallet!.address),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Wallet\'s address has been copied to the clipboard',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
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
                                      widget.userUsecase.signOut();
                                      CustomRouter.navigateTo(context, Routes.auth);
                                    },
                                  ),
                                ],
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
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.account_balance_wallet_rounded,
                                            color: Colors.orange,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Total Portfolio Value',
                                          style: TextStyle(color: Colors.white70, fontSize: 16),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        widget.isShowBalance
                                            ? Text(
                                              '\$${totalBalance.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 36,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                            : Text(
                                              '•' * 8,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 36,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                        const Spacer(),
                                        widget.isShowBalance
                                            ? GestureDetector(
                                              child: Icon(
                                                Icons.visibility,
                                                color: Colors.white70,
                                                size: 20,
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  widget.isShowBalance = !widget.isShowBalance;
                                                });
                                              },
                                            )
                                            : GestureDetector(
                                              child: Icon(
                                                Icons.visibility_off,
                                                color: Colors.white70,
                                                size: 20,
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  widget.isShowBalance = !widget.isShowBalance;
                                                });
                                              },
                                            ),
                                      ],
                                    ),
                                    const Text(
                                      'Real-time pricing',
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
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
                        DefaultTabController(
                          length: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TabBar(
                                labelColor: Colors.blue,
                                unselectedLabelColor: Colors.grey,
                                indicatorColor: Colors.blue,
                                tabs: [Tab(text: "Tokens"), Tab(text: "NFTs")],
                              ),
                              SizedBox(
                                height: 200,
                                child: TabBarView(
                                  children: [
                                    ListView.builder(
                                      itemCount: provider.getAssetByType("TOKEN").length,
                                      itemBuilder: (context, index) {
                                        return AssetCard(
                                          assetSymbol:
                                              provider.getAssetByType("TOKEN")[index].assetSymbol,
                                          balance: provider.getAssetByType("TOKEN")[index].balance,
                                          assetBalance: weiToEth(
                                            provider.getAssetByType("TOKEN")[index].assetBalance,
                                          ),
                                          lastChange:
                                              provider.getAssetByType("TOKEN")[index].last24hChange,
                                        );
                                      },
                                    ),
                                    provider.getNftItem() != null
                                        ? ListView.builder(
                                          itemCount: provider.getNftItem()!.length,
                                          // physics: NeverScrollableScrollPhysics(), // disable inner scrolling
                                          // shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return NftCard(
                                              nftName: provider.getNftItem()![index].name,
                                              type: 'NFT',
                                              id: provider.getNftItem()![index].tokenId,
                                              nftType: '',
                                              // assetSymbol:provider.getNftItem()![index].name,
                                              // balance: provider.getNftItem()![index].symbol,
                                              // assetBalance: 0,
                                              // lastChange:
                                              //     0,
                                            );
                                          },
                                        )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),
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
