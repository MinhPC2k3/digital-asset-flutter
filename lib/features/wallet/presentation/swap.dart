import 'package:digital_asset_flutter/features/wallet/presentation/swap_review.dart';
import 'package:flutter/material.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({super.key});

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  String amount = "500,000";
  String ethAmount = "0.00743586";
  String btcAmount = "0.00015811";
  String availableBalance = "632,072";

  void _onNumberPressed(String number) {
    setState(() {
      if (amount == '0') {
        amount = number;
      } else {
        amount += number;
      }
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (amount.length > 1) {
        amount = amount.substring(0, amount.length - 1);
      } else {
        amount = '0';
      }
    });
  }

  void _onUseMaxPressed() {
    setState(() {
      amount = '636062'; // Max available amount
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAmountDisplay(),
                    const SizedBox(height: 24),
                    _buildSwapSection(),
                    _buildMinMaxButtons(),
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Column(
                        children: [
                          // Row 1
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildNumberButton('1'),
                              _buildNumberButton('2'),
                              _buildNumberButton('3'),
                            ],
                          ),
                          // Row 2
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildNumberButton('4'),
                              _buildNumberButton('5'),
                              _buildNumberButton('6'),
                            ],
                          ),
                          // Row 3
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildNumberButton('7'),
                              _buildNumberButton('8'),
                              _buildNumberButton('9'),
                            ],
                          ),
                          // Row 4
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: Container()),
                              _buildNumberButton('0'),
                              _buildBackspaceButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildContinueButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFFF5A623), size: 18),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Send',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Main Wallet',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: Color(0xFFF5A623),
              size: 22,
            ),
            onPressed: () {
              // Show info
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'đ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$ethAmount ETH',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5A623).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.sync, color: Color(0xFFF5A623), size: 26),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'đ$availableBalance available',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwapSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2023),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildCurrencyRow(
            'Send',
            ethAmount,
            'assets/ethereum_logo.png',
            Colors.white,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 16),
          _buildCurrencyRow(
            'Get',
            btcAmount,
            'assets/bitcoin_logo.png',
            Color(0xFFF7931A),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow(
    String label,
    String amount,
    String logoPath,
    Color logoColor,
  ) {
    return Row(
      children: [
        _buildCryptoLogo(logoPath, logoColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (label == 'Send')
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.swap_vert, color: Colors.white),
          ),
      ],
    );
  }

  Widget _buildCryptoLogo(String path, Color color) {
    // In a real app, you would use Image.asset(path)
    // For this example, we'll use a placeholder
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child:
            path.contains('ethereum')
                ? const Icon(
                  Icons.currency_exchange,
                  color: Colors.white,
                  size: 18,
                )
                : const Icon(
                  Icons.currency_bitcoin,
                  color: Colors.white,
                  size: 18,
                ),
      ),
    );
  }

  Widget _buildMinMaxButtons() {
    return Row(
      children: [
        Expanded(child: _buildActionButton('Min', const Color(0xFF8B4513))),
        Expanded(child: _buildActionButton('Max', const Color(0xFF8B4513))),
      ],
    );
  }

  Widget _buildActionButton(String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Use Max',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNumberPressed(number),
        child: Container(
          height: 30,
          margin: EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Expanded(
      child: GestureDetector(
        onTap: _onBackspacePressed,
        child: Container(
          height: 30,
          margin: EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              Icons.backspace_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SwapReviewScreen()),
          );
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
