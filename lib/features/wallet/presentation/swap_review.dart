import 'package:flutter/material.dart';

class SwapReviewScreen extends StatelessWidget {
  const SwapReviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define text styles based on requirements
    final TextStyle bigTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    final TextStyle normalTextStyle = TextStyle(
      fontSize: 14,
      color: Colors.white,
    );

    final TextStyle smallTextStyle = TextStyle(
      fontSize: 12,
      color: Colors.white.withOpacity(0.7),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D31),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Swap',
                          style: bigTextStyle.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 10),
                        _buildSwapDetails(
                          bigTextStyle,
                          normalTextStyle,
                          smallTextStyle,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Fees',
                          style: bigTextStyle.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 10),
                        _buildFeesSection(
                          bigTextStyle,
                          normalTextStyle,
                          smallTextStyle,
                        ),
                        const SizedBox(height: 10),
                        _buildInfoMessage(normalTextStyle),
                        const SizedBox(height: 20),
                        Text(
                          'Network',
                          style: bigTextStyle.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 10),
                        _buildNetworkSection(
                          bigTextStyle,
                          normalTextStyle,
                          smallTextStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0,10,10,0),
                child: _buildSlideToConfirm(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFFF5A623),
              size: 18,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const Text(
            'Review',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 40), // Balance the header
        ],
      ),
    );
  }

  Widget _buildSwapDetails(
    TextStyle bigTextStyle,
    TextStyle normalTextStyle,
    TextStyle smallTextStyle,
  ) {
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
            'ETH',
            '0.00743586 ETH',
            'assets/ethereum_logo.png',
            smallTextStyle,
            bigTextStyle,
            normalTextStyle,
          ),
          const SizedBox(height: 20),
          _buildCurrencyRow(
            'Get',
            'BTC',
            '0.00015811 BTC',
            'assets/bitcoin_logo.png',
            smallTextStyle,
            bigTextStyle,
            normalTextStyle,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Fixed Rate', style: bigTextStyle),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFFF5A623),
                    size: 18,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('1 ETH', style: normalTextStyle),
                  Text('= 0.02126318 BTC', style: normalTextStyle),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow(
    String label,
    String currency,
    String amount,
    String logoPath,
    TextStyle smallTextStyle,
    TextStyle bigTextStyle,
    TextStyle normalTextStyle,
  ) {
    return Row(
      children: [
        _buildCryptoLogo(logoPath, currency),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: smallTextStyle),
            Text(currency, style: bigTextStyle),
          ],
        ),
        const Spacer(),
        Text(amount, style: normalTextStyle),
      ],
    );
  }

  Widget _buildCryptoLogo(String path, String currency) {
    Color bgColor =
        currency == 'ETH' ? const Color(0xFF627EEA) : const Color(0xFFF7931A);

    IconData iconData =
        currency == 'ETH' ? Icons.currency_exchange : Icons.currency_bitcoin;

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

  Widget _buildFeesSection(
    TextStyle bigTextStyle,
    TextStyle normalTextStyle,
    TextStyle smallTextStyle,
  ) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2023),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('Network', style: bigTextStyle),
              const SizedBox(width: 5),
              Icon(
                Icons.info_outline,
                color: const Color(0xFFF5A623),
                size: 18,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text('đ', style: normalTextStyle),
                  Text('13,502', style: normalTextStyle),
                ],
              ),
              Text('0.0002 ETH', style: smallTextStyle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMessage(TextStyle normalTextStyle) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4B2E83),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Network fee is paid on top of amount swapped',
              style: normalTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkSection(
    TextStyle bigTextStyle,
    TextStyle normalTextStyle,
    TextStyle smallTextStyle,
  ) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2023),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estimated Time', style: bigTextStyle),
                  Text('5-30 minutes', style: smallTextStyle),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildCryptoLogo('assets/ethereum_logo.png', 'ETH'),
              const SizedBox(width: 10),
              Text('Ethereum', style: bigTextStyle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlideToConfirm(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5A623),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
