import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';
import 'package:digital_asset_flutter/features/wallet/domain/usecases/wallet_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/route.dart';
import '../../auth/presentation/provider/user_provider.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({Key? key, required this.wallerUsecases}) : super(key: key);

  final WalletUsecases wallerUsecases;

  @override
  _CreateWalletScreenState createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  final TextEditingController _walletNameController = TextEditingController();
  String _selectedNetwork = 'Ethereum';
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  final List<bool> _pinFilledStatus = List.generate(6, (_) => false);

  final TextEditingController _confirmPinController = TextEditingController();
  final FocusNode _confirmPinFocusNode = FocusNode();
  final List<bool> _confirmPinFilledStatus = List.generate(6, (_) => false);

  @override
  void dispose() {
    _walletNameController.dispose();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _updatePinFilledStatus() {
    final pin = _pinController.text;
    setState(() {
      for (int i = 0; i < 6; i++) {
        _pinFilledStatus[i] = i < pin.length;
      }
    });
  }

  void _updateConfirmPinFilledStatus() {
    final pin = _confirmPinController.text;
    setState(() {
      for (int i = 0; i < 6; i++) {
        _confirmPinFilledStatus[i] = i < pin.length;
      }
    });
  }

  bool get _isFormValid => _walletNameController.text.isNotEmpty && _pinController.text.length == 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text('Create New Wallet', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wallet Name',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _walletNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter wallet name',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Network',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildNetworkOption('Ethereum', 'ETH Network', Icons.currency_exchange, Colors.white),
              const SizedBox(height: 8),
              _buildNetworkOption('Binance', 'BNB Network', Icons.currency_franc, Colors.amber),
              const SizedBox(height: 24),
              const Text(
                'Security PIN (6 digits)',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Enter a 6-digit PIN to secure your wallet',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              _buildPinInput(
                _pinController,
                _pinFocusNode,
                _pinFilledStatus,
                _updatePinFilledStatus,
              ),
              const Text(
                'Repeat pin',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              _buildPinInput(
                _confirmPinController,
                _confirmPinFocusNode,
                _confirmPinFilledStatus,
                _updateConfirmPinFilledStatus,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isFormValid
                          ? () async {
                            if (_pinController.text != _confirmPinController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Repeat pin mismatch'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            // Handle wallet creation
                            var createdWallet = await widget.wallerUsecases.createWallet(
                              Provider.of<UserProvider>(context, listen: false).user!.id,
                              _walletNameController.text,
                              _selectedNetwork.toLowerCase(),
                              _pinController.text,
                            );
                            if (!createdWallet.isSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${createdWallet.error!.message}')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Wallet created successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Provider.of<WalletProvider>(
                                context,
                                listen: false,
                              ).setWallet(createdWallet.data!);
                              CustomRouter.navigateTo(context, Routes.home);
                            }
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    disabledBackgroundColor: Colors.amber.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Create Wallet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkOption(String name, String subtitle, IconData icon, Color iconColor) {
    final isSelected = _selectedNetwork == name;
    return GestureDetector(
      onTap: () => setState(() => _selectedNetwork = name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.amber : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.amber.withOpacity(0.2) : Colors.black26,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              ],
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.amber),
          ],
        ),
      ),
    );
  }

  // final TextEditingController _confirmPinController = TextEditingController();
  // final FocusNode _confirmPinFocusNode = FocusNode();
  // final List<bool>
  Widget _buildPinInput(
    TextEditingController textController,
    FocusNode focusNode,
    List<bool> isFilled,
    void Function() updateFunction,
  ) {
    return Stack(
      children: [
        // Hidden text field for actual input
        Positioned(
          left: -999,
          top: 0,
          child: SizedBox(
            width: 1,
            height: 1,
            child: TextField(
              controller: textController,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              onChanged: (value) {
                updateFunction();
                setState(() {});
              },
            ),
          ),
        ),
        // PIN display dots
        GestureDetector(
          onTap: () => focusNode.requestFocus(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (index) => Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled[index] ? Colors.amber : Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
