import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/homepage_provider.dart';

class BalanceSection extends StatelessWidget {
  const BalanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomepageProvider>(
      builder: (context, homepageProvider, child) {
        return Container(
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
                      'Total Portfolio Value',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        homepageProvider.isShowBalance
                            ? Text(
                              '\$${homepageProvider.currentWallet.totalValue.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
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
                        homepageProvider.isShowBalance
                            ? GestureDetector(
                              onTap: homepageProvider.changeShowBalance,
                              child: Icon(Icons.visibility, color: Colors.white70, size: 20),
                            )
                            : GestureDetector(
                              onTap: homepageProvider.changeShowBalance,
                              child: Icon(Icons.visibility_off, color: Colors.white70, size: 20),
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
        );
      },
    );
  }
}
