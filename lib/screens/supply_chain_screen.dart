import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register_product_screen.dart';
import 'record_handoff_screen.dart';
import 'product_history_screen.dart';
import 'hobbyist_tracking_screen.dart';
import '../services/auth_service.dart';

class SupplyChainScreen extends StatefulWidget {
  @override
  _SupplyChainScreenState createState() => _SupplyChainScreenState();
}

class _SupplyChainScreenState extends State<SupplyChainScreen> {
  int _currentIndex = 0;

  final List<Widget> _farmerScreens = [
    RegisterProductScreen(),
    RecordHandoffScreen(),
    ProductHistoryScreen(),
  ];
  
  final List<String> _screenTitles = [
    'Register Product',
    'Record Handoff',
    'Product History',
  ];
  
  final List<IconData> _screenIcons = [
    Icons.add_box,
    Icons.swap_horiz,
    Icons.history,
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final String? userType = authService.userType;
    
    // Show loading indicator while determining user type
    if (userType == null && authService.isLoggedIn) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Show hobbyist view if user is a hobbyist
    if (userType == 'hobbyist') {
      // Use Navigator to push the HobbyistTrackingScreen
      Future.microtask(() => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HobbyistTrackingScreen())
      ));
      
      // Return a loading screen while navigation happens
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Default farmer view
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE5F0E7),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF5F8F58)),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.only(left: 20, top: 20), 
        ),
        actions: [
          // Toggle dropdown button
          PopupMenuButton<int>(
            icon: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_screenIcons[_currentIndex], color: Color(0xFF5F8F58), size: 20),
                  Icon(Icons.arrow_drop_down, color: Color(0xFF5F8F58)),
                ],
              ),
            ),
            onSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context) => [
              for (int i = 0; i < _screenIcons.length; i++)
                PopupMenuItem<int>(
                  value: i,
                  child: Row(
                    children: [
                      Icon(_screenIcons[i], 
                        color: _currentIndex == i ? Color(0xFF5F8F58) : Colors.grey,
                      ),
                      SizedBox(width: 12),
                      Text(_screenTitles[i]),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(width: 8),
        ],
      ),
      body: _farmerScreens[_currentIndex],
      // Removed the bottom navigation bar
    );
  }
}