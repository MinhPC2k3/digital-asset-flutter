import 'package:digital_asset_flutter/core/helper/helper.dart';
import 'package:digital_asset_flutter/features/auth/domain/entities/user.dart';
import 'package:digital_asset_flutter/features/transaction/data/source/network/transaction_datasource.dart';
import 'package:digital_asset_flutter/features/transaction/domain/entities/transaction.dart';
import 'package:digital_asset_flutter/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:digital_asset_flutter/features/transaction/domain/usecases/transaction_usecases.dart';
import 'package:digital_asset_flutter/features/transaction/presentation/transaction_confirm.dart';
import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class TransactionReviewScreen extends StatelessWidget {
  final String amount;
  final String receiverAddress;
  late final TransactionUsecase transactionUsecase;
  late final TransactionRepository transactionRepository;

  TransactionReviewScreen({super.key, required this.amount, required this.receiverAddress}) {
    transactionRepository = TransactionRepositoryImpl(http.Client());
    transactionUsecase = TransactionUsecase(transactionRepository: transactionRepository);
  }

  void _showPinBottomModal(BuildContext context, Transaction transaction, SignInfo signInfo) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder:
          (context) => PinKeyboardModal(
            transactionUsecase: transactionUsecase,
            signInfo: signInfo,
            transaction: transaction,
          ),
    );

    if (result == true) {
      // PIN verified successfully, proceed with transaction
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: Colors.orange, size: 24),
        ),
        title: Column(
          children: [
            const Text(
              'Review',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text('Main Wallet', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Section
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            'Ξ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$amount ETH',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // const Text(
                          //   '0.00738922 ETH',
                          //   style: TextStyle(color: Colors.grey, fontSize: 16),
                          // ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

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
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.open_in_new, color: Colors.orange, size: 20),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Transaction Speed Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaction Speed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Regular ~ 3-15 min',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      Icon(Icons.edit, color: Colors.orange, size: 20),
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
                                children: [
                                  const Text(
                                    'Network Fee',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                          const Text(
                            'd11,837',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '0.00017571 ETH',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Network Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Network',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Ξ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Ethereum',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            var transaction = Transaction(
                              userId: Provider.of<UserProvider>(context, listen: false).user!.id,
                              walletId:
                                  Provider.of<WalletProvider>(context, listen: false).wallet!.id,
                              assetId: "asset-eth-0001",
                              amount: amount,
                              receiverAddress: receiverAddress,
                              blockchainType: BlockchainType.BLOCKCHAIN_TYPE_ETHEREUM,
                              networkName: "ethereum",
                              transactionType: TransactionType.TX_TYPE_NATIVE_TRANSFER,
                            );
                            var signResponse = await transactionUsecase.prepareSign(transaction);

                            if (!signResponse.isSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error when create transaction: ${signResponse.error!.message}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            _showPinBottomModal(context, transaction, signResponse.data!);

                            // CustomRouter.navigateTo(context, Routes.home);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Send',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
