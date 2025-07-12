import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../auth/presentation/provider/user_provider.dart';
import '../data/network/wallet_datasources.dart';
import '../domain/usecases/wallet_usecase.dart';
import 'create_wallet.dart';

// Wallet Selector Modal
class WalletSelectorModal extends StatefulWidget {
  const WalletSelectorModal({super.key, required this.walletUsecases});

  final WalletUsecases walletUsecases;

  @override
  WalletSelectorModalState createState() => WalletSelectorModalState();
}

class WalletSelectorModalState extends State<WalletSelectorModal> {
  late Future<Result<List<Wallet>>> _fetchData;
  bool _errorHandled = false;


  @override
  void initState() {
    super.initState();
    _fetchData = _initialize(Provider.of<UserProvider>(context, listen: false).user!.id);
  }

  Future<Result<List<Wallet>>> _initialize(String userId) async {
    Result<List<Wallet>> listWallets = await widget.walletUsecases.getUserWallet(userId);
    return listWallets;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<List<Wallet>>>(
      future: _fetchData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError && !_errorHandled) {
          _errorHandled = true;

          // Delay execution to safely access context
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${snapshot.error}')));
            Navigator.pop(context);
          });
          // Return empty container during frame
          return Container();
        } else {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.close, color: Colors.orange, size: 24),
                          ),
                          const Text(
                            'My Accounts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            'Edit',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Wallets Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Wallets',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main Wallet Item
                    snapshot.data!.data!.isEmpty
                        ? Container()
                        : Expanded(child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // height: 120,

                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          // physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.data!.length,
                          itemBuilder: (context, index) {
                            final wallet = snapshot.data!.data![index];
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: _buildWalletItem(wallet, index),
                            );
                          },
                        ),
                      ),
                    ),),
                    Container(height: 8,),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          CreateWalletScreen(wallerUsecases: widget.walletUsecases),
                                  fullscreenDialog: true,
                                ),
                              );
                              if (result != null && result is Map<String, String>) {
                                final walletName = result['walletName'];
                                final networkId = result['networkId'];

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Wallet "$walletName" created on $networkId network!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    'Create New Wallet',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildWalletItem(Wallet wallet, int index) {
    final isSelected = Provider.of<WalletProvider>(context, listen: true).walletIndex == index;

    return GestureDetector(
      onTap: () async {
        var walletRepo = WalletRepositoryImpl(http.Client());
        var assetBalanceResult = await WalletUsecases(walletRepository: walletRepo).getWalletAssetBalances(wallet);
        if (assetBalanceResult.isSuccess){
          wallet.assetBalances = assetBalanceResult.data!.assetBalances;
        }
        setState(() {
          Provider.of<WalletProvider>(context, listen: false).setWalletIndexValue(index);
          Provider.of<WalletProvider>(context, listen: false).setWallet(wallet);
        });
        Navigator.pop(context);
      },
      child: Container(
        // margin: index != 1 ? EdgeInsets.only(top: 0) : EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: const Color(0xFFFF9800), width: 1) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.account_balance_wallet, color: Color(0xFFFF9800), size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.walletName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    wallet.networkName,
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(color: Color(0xFFFF9800), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
