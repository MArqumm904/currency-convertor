import 'package:currensee/Admin/adminscreens/convertions.dart';
import 'package:currensee/Admin/adminscreens/currensies.dart';
import 'package:currensee/Admin/adminscreens/services.dart';
import 'package:currensee/Admin/adminscreens/users.dart';
import 'package:currensee/Admin/widgets/custom_bottom_navigationbar.dart'; // Import the custom navigation bar
import 'package:currensee/Auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Sample data
  final int totalUsers = 120;
  final int totalConversions = 80;
  final int totalCurrencies = 50;
  final int totalServices = 30;

  int _selectedIndex = 0;

  List<Widget> _pages = [
    Users(),
    Convertions(),
    Currensies(),
    Services(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('role');

    Fluttertoast.showToast(
      msg: "Logged out successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) =>
              const LoginScreen()), // Ensure to import your LoginScreen
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(color: Colors.white54),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context), // Call the _logout method
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _onItemTapped(0);
                      },
                      child: _buildCard('Total Users', totalUsers),
                    ),
                    GestureDetector(
                      onTap: () {
                        _onItemTapped(1);
                      },
                      child: _buildCard('Total Conversions', totalConversions),
                    ),
                    GestureDetector(
                      onTap: () {
                        _onItemTapped(2);
                      },
                      child: _buildCard('Total Currencies', totalCurrencies),
                    ),
                    GestureDetector(
                      onTap: () {
                        _onItemTapped(3);
                      },
                      child: _buildCard('Total Services', totalServices),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            _onItemTapped(index);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => _pages[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(String title, int count) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.tealAccent.withOpacity(0.8),
            Colors.tealAccent.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const AdminScreen());
}
