import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/homepage/action_button.dart';
import '../components/homepage/asset_display.dart';
import '../components/homepage/balance_section.dart';
import '../components/homepage/hompage_header.dart';
import '../components/homepage/security_level.dart';
import '../provider/homepage_provider.dart';

class GeneralInfo extends StatefulWidget {
  const GeneralInfo({super.key});

  @override
  GeneralInfoState createState() => GeneralInfoState();
}

class GeneralInfoState extends State<GeneralInfo> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<HomepageProvider>().loadUserWallets();
    });
    Provider.of<HomepageProvider>(context, listen: false).updateBalanceByInterval();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomepageProvider>(
      builder: (context, homepageProvider, child) {
        return homepageProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Scaffold(
              backgroundColor: const Color(0xFF1A1A1A),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Header
                            HomepageHeader(),

                            const SizedBox(height: 30),

                            // Balance Section with Background
                            BalanceSection(),

                            const SizedBox(height: 30),

                            // Action Buttons
                            ActionButton(),

                            const SizedBox(height: 20),

                            // Asset display
                            AssetDisplay(),

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
