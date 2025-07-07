import 'package:digital_asset_flutter/features/transaction_swap_v2/presentation/providers/swap_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'swap_page.dart';

class SimpleSwapInterface extends StatefulWidget {
  const SimpleSwapInterface({super.key});

  @override
  SimpleSwapInterfaceState createState() => SimpleSwapInterfaceState();
}

class SimpleSwapInterfaceState extends State<SimpleSwapInterface> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final swapProvider = context.read<SwapProvider>();
      swapProvider.setOtherWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwapPage();
  }
}
