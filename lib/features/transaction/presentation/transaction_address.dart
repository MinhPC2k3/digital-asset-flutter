import 'package:digital_asset_flutter/features/transaction/presentation/transaction_review.dart';
import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';
import 'package:digital_asset_flutter/features/wallet/domain/usecases/wallet_usecase.dart';
import 'package:flutter/material.dart';

import '../../../core/helper/helper.dart';

class SendAddressScreen extends StatefulWidget {
  final Wallet wallet;
  final int assetId;

  const SendAddressScreen({super.key, required this.wallet, required this.assetId});

  @override
  State<SendAddressScreen> createState() => _SendAddressScreenState();
}

class _SendAddressScreenState extends State<SendAddressScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isValidAddress = false;
  bool _isValidAmount = false;

  void _validateAddress(String address) {
    // Simple Ethereum address validation (starts with 0x and 42 characters)
    setState(() {
      _isValidAddress = address.startsWith('0x') && address.length == 42;
    });
  }

  void _proceedToReview(String amountInput) {
    print("On click continue");
    setState(() {
      try {
        var amount = double.parse(_amountController.text);
        _isValidAmount = amount > 0;
      } catch (e) {
        throw FormatException('Invalid amount format: "$amountInput"');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2A2A2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text('Send', style: TextStyle(color: Colors.white, fontSize: 18)),
            Text(
              widget.wallet.walletName,
              style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected asset info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF627EEA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.currency_bitcoin, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.wallet.assetBalances![widget.assetId].assetSymbol,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Balance: ${cleanDecimal(weiToEth(widget.wallet.assetBalances![widget.assetId].assetBalance))} ${widget.wallet.assetBalances![widget.assetId].assetSymbol}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recipient address section
            const Text(
              'Recipient Address',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Address input field
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isValidAddress ? const Color(0xFFFF6B35) : Colors.transparent,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _addressController,
                onChanged: _validateAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '0x... or ENS name',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  // suffixIcon: Row(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //     IconButton(
                  //       icon: Icon(Icons.qr_code_scanner, color: Colors.grey[400]),
                  //       onPressed: _scanQRCode,
                  //     ),
                  //     IconButton(
                  //       icon: Icon(Icons.paste, color: Colors.grey[400]),
                  //       onPressed: _pasteFromClipboard,
                  //     ),
                  //   ],
                  // ),
                ),
              ),
            ),

            if (_isValidAddress)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Valid Ethereum address',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Amount section
            const Text(
              'Amount',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _amountController,
                onChanged: _proceedToReview,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.wallet.assetBalances![widget.assetId].assetSymbol, style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            _amountController.text = cleanDecimal(weiToEth(widget.wallet.assetBalances![widget.assetId].assetBalance));
                          },
                          child: const Text(
                            'MAX',
                            style: TextStyle(
                              color: Color(0xFFFF6B35),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isValidAddress && _isValidAmount
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => TransactionReviewScreen(amount: _amountController.text, receiverAddress: _addressController.text, assetBalance: widget.wallet.assetBalances![widget.assetId],),
                              fullscreenDialog: true,
                            ),
                          );
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  disabledBackgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }
}
