import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({Key? key}) : super(key: key);

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  final TextEditingController walletNameController = TextEditingController();
  String selectedNetwork = 'Ethereum';
  String securityPin = '';
  String confirmPin = '';
  bool showConfirmPin = false;
  bool pinMismatch = false;

  final List<NetworkOption> networks = [
    NetworkOption(
      name: 'Ethereum',
      subtitle: 'ETH Network',
      icon: '⟠',
      color: const Color(0xFFFFD700),
    ),
    NetworkOption(
      name: 'Binance',
      subtitle: 'BNB Network',
      icon: 'B',
      color: const Color(0xFFFFD700),
    ),
  ];

  void _onPinChanged(String pin, bool isConfirm) {
    setState(() {
      if (isConfirm) {
        confirmPin = pin;
        pinMismatch = confirmPin.isNotEmpty && confirmPin != securityPin;
      } else {
        securityPin = pin;
        if (pin.length == 6) {
          showConfirmPin = true;
        } else {
          showConfirmPin = false;
          confirmPin = '';
          pinMismatch = false;
        }
      }
    });
  }

  bool get canCreateWallet {
    return walletNameController.text.isNotEmpty &&
        securityPin.length == 6 &&
        confirmPin.length == 6 &&
        securityPin == confirmPin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1B23),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create New Wallet',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Name Section
            const Text(
              'Wallet Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: walletNameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter wallet name',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFF2A2B35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),

            const SizedBox(height: 24),

            // Select Network Section
            const Text(
              'Select Network',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            ...networks.map((network) => _buildNetworkOption(network)),

            const SizedBox(height: 24),

            // Security PIN Section
            const Text(
              'Security PIN (6 digits)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            NoCursorPinWidget(
              pin: securityPin,
              onPinChanged: (pin) => _onPinChanged(pin, false),
              label: 'Enter a 6-digit PIN to secure your wallet',
            ),

            // Confirm PIN Section (shows when first PIN is complete)
            if (showConfirmPin) ...[
              const SizedBox(height: 24),
              const Text(
                'Confirm PIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              NoCursorPinWidget(
                pin: confirmPin,
                onPinChanged: (pin) => _onPinChanged(pin, true),
                label: 'Re-enter your PIN to confirm',
                hasError: pinMismatch,
                errorMessage: pinMismatch ? 'PINs do not match' : null,
              ),
            ],

            const SizedBox(height: 40),

            // Create Wallet Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canCreateWallet ? _createWallet : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canCreateWallet
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF3A3B45),
                  foregroundColor: canCreateWallet
                      ? Colors.black
                      : const Color(0xFF9CA3AF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Create Wallet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkOption(NetworkOption network) {
    bool isSelected = selectedNetwork == network.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedNetwork = network.name;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2B35),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? network.color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3B45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    network.icon,
                    style: TextStyle(
                      color: network.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      network.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      network.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: network.color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _createWallet() {
    // Handle wallet creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wallet created successfully!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }
}

class NoCursorPinWidget extends StatefulWidget {
  final String pin;
  final Function(String) onPinChanged;
  final String label;
  final bool hasError;
  final String? errorMessage;

  const NoCursorPinWidget({
    Key? key,
    required this.pin,
    required this.onPinChanged,
    required this.label,
    this.hasError = false,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<NoCursorPinWidget> createState() => _NoCursorPinWidgetState();
}

class _NoCursorPinWidgetState extends State<NoCursorPinWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.pin);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(NoCursorPinWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pin != oldWidget.pin) {
      _controller.text = widget.pin;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTap() {
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PIN Display with invisible TextField
        Stack(
          children: [
            // Visible PIN dots
            GestureDetector(
              onTap: _onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    bool isFilled = index < widget.pin.length;
                    bool hasError = widget.hasError && widget.pin.length == 6;
                    bool isFocused = _focusNode.hasFocus && index == widget.pin.length;

                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: hasError
                              ? Colors.red
                              : isFocused
                              ? const Color(0xFFFFD700)
                              : const Color(0xFF3A3B45),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isFilled
                            ? Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasError
                                ? Colors.red
                                : const Color(0xFFFFD700),
                          ),
                        )
                            : null,
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Invisible TextField positioned off-screen
            Positioned(
              left: -9999,
              top: 0,
              child: SizedBox(
                width: 1,
                height: 1,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  style: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 1,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  showCursor: false,
                  onChanged: (value) {
                    widget.onPinChanged(value);
                  },
                ),
              ),
            ),
          ],
        ),

        Text(
          widget.errorMessage ?? widget.label,
          style: TextStyle(
            color: widget.hasError ? Colors.red : const Color(0xFF9CA3AF),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class NetworkOption {
  final String name;
  final String subtitle;
  final String icon;
  final Color color;

  NetworkOption({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class TestScreen extends StatelessWidget{
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CreateWalletScreen(),
    );
  }

}