import 'package:digital_asset_flutter/features/user_v2/presentation/pages/general_info.dart';
import 'package:flutter/material.dart';

import '../../../transaction_history_v2/presentation/pages/transaction_history.dart';

class MyHomeRefactoredPage extends StatefulWidget {
  const MyHomeRefactoredPage({super.key});

  @override
  MyHomeRefactoredPageState createState() => MyHomeRefactoredPageState();
}

class MyHomeRefactoredPageState extends State<MyHomeRefactoredPage> {
  int _currentIndex = 0;

  // Define your pages/screens
  final List<Widget> _pages = [
    GeneralInfo(),
    TransactionHistoryPage(),
    Center(child: Text('Profile Page')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _pages[_currentIndex], // Show selected page
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[900],
        // Background color
        selectedItemColor: Color(0xFFFF6B35),
        // Color of the selected item
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Change current index
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Security'),
        ],
      ),
    );
  }
}
