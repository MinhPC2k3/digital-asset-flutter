import 'package:digital_asset_flutter/features/transaction_swap_v2/domain/entities/quote.dart';
import 'package:flutter/material.dart';

class SwapDetailsSection extends StatelessWidget {
  final TransactionQuote quote;
  final TextStyle bigTextStyle;
  final TextStyle normalTextStyle;
  final TextStyle smallTextStyle;

  const SwapDetailsSection({
    Key? key,
    required this.quote,
    required this.bigTextStyle,
    required this.normalTextStyle,
    required this.smallTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2023),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildCurrencyRow(
            'Send',
            quote.fromAsset.symbol,
            '${quote.amountSwap} ${quote.fromAsset.symbol}',
          ),
          const SizedBox(height: 20),
          _buildCurrencyRow(
            'Get',
            quote.toAsset.symbol,
            '${quote.amountReceive} ${quote.toAsset.symbol}',
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Fixed Rate', style: bigTextStyle),
                  const SizedBox(width: 5),
                  Icon(Icons.info_outline, color: const Color(0xFFF5A623), size: 18),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('1 ${quote.fromAsset.symbol}', style: normalTextStyle),
                  Text('= ${quote.rate} ${quote.toAsset.symbol}', style: normalTextStyle),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow(String label, String currency, String amount) {
    return Row(
      children: [
        _buildCryptoLogo(currency),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: smallTextStyle),
            Text(currency, style: bigTextStyle)
          ],
        ),
        const Spacer(),
        Text(amount, style: normalTextStyle),
      ],
    );
  }

  Widget _buildCryptoLogo(String currency) {
    Color bgColor = currency == 'ETH' ? const Color(0xFF627EEA) : const Color(0xFFF7931A);
    IconData iconData = currency == 'ETH' ? Icons.currency_exchange : Icons.currency_bitcoin;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(iconData, color: Colors.white, size: 18),
        ),
      ),
    );
  }
} 