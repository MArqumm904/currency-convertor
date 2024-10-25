import 'package:currensee/Port/port.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:currensee/Auth/login_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  // Controllers for filter fields
  final TextEditingController _baseCurrencyController = TextEditingController();
  final TextEditingController _convertedCurrencyController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  List<dynamic> conversionHistory = [];
  List<dynamic> filteredHistory = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
    _fetchConversionHistory();
  }

  Future<void> _updateUser() async {
    final String apiUrl = '$port/updateuser.php';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': _emailController.text,
        'name': _nameController.text,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        Fluttertoast.showToast(
          msg: "User updated successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        _nameController.clear();
        _emailController.clear();
      } else {
        Fluttertoast.showToast(
          msg: data['message'] ?? "Email not found.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Failed to update user.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });
    print("User ID: $userId");

    if (userId != null) {
      _fetchConversionHistory();
      _fetchUserDetails(userId!);
    }
  }

  Future<void> _fetchUserDetails(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$port/getnamebyid.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": id}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          setState(() {
            _nameController.text = data['data']['name'];
            _emailController.text = data['data']['email'];
          });
        } else {
          print(data['message']);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message']))
          );
        }
      } else {
        print("Failed to fetch user details. Status code: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch user details'))
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error occurred'))
      );
    }
  }

  Future<void> _fetchConversionHistory() async {
    if (userId == null) return;

    final url = '$port/get_conversion_history.php?user_id=$userId';
    print("API URL: $url");

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        setState(() {
          conversionHistory = json.decode(response.body);
          filteredHistory = conversionHistory; // Initialize filtered list
        });
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    } else {
      print("Failed to fetch conversion history: ${response.statusCode}");
    }
  }

  void _applyFilters() {
    setState(() {
      filteredHistory = conversionHistory.where((conversion) {
        bool matchesBaseCurrency = true;
        bool matchesConvertedCurrency = true;
        bool matchesAmount = true;

        if (_baseCurrencyController.text.isNotEmpty) {
          matchesBaseCurrency = conversion['from_currency']
              .toString()
              .toLowerCase()
              .contains(_baseCurrencyController.text.toLowerCase());
        }

        if (_convertedCurrencyController.text.isNotEmpty) {
          matchesConvertedCurrency = conversion['to_currency']
              .toString()
              .toLowerCase()
              .contains(_convertedCurrencyController.text.toLowerCase());
        }

        if (_amountController.text.isNotEmpty) {
          double filterAmount = double.tryParse(_amountController.text) ?? 0;
          double conversionAmount = double.tryParse(conversion['amount'].toString()) ?? 0;
          matchesAmount = conversionAmount >= filterAmount;
        }

        return matchesBaseCurrency && matchesConvertedCurrency && matchesAmount;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _baseCurrencyController.clear();
      _convertedCurrencyController.clear();
      _amountController.clear();
      filteredHistory = conversionHistory;
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
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Color(0xFF0A0E21),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white54),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/adminimages/avatar.png'),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _nameController, label: 'Name'),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _emailController, label: 'Email'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _updateUser,
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Conversion History',
                style: TextStyle(color: Colors.white54, fontSize: 20),
              ),
              const SizedBox(height: 16),
              _buildConversionFilterSection(),
              const SizedBox(height: 16),
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: filteredHistory.isEmpty
                    ? Center(
                        child: Text(
                          'No matching conversions found',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredHistory.length,
                        itemBuilder: (context, index) {
                          final conversion = filteredHistory[index];
                          return Card(
                            color: Colors.white12,
                            child: ListTile(
                              title: Text(
                                '${conversion['from_currency']} to ${conversion['to_currency']}',
                                style: const TextStyle(color: Colors.white54),
                              ),
                              subtitle: Text(
                                'Amount: ${conversion['amount']} \nConversion Amount: ${conversion['total']} \nDate: ${conversion['conversion_date']}',
                                style: const TextStyle(color: Colors.white54),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white54),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterTextField({
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required void Function(String) onChanged,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white54),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.white54),
      ),
    );
  }

  Widget _buildConversionFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildFilterTextField(
                label: 'Base Currency',
                icon: Icons.monetization_on,
                onChanged: (value) => _applyFilters(),
                controller: _baseCurrencyController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFilterTextField(
                label: 'Converted Currency',
                icon: Icons.currency_exchange,
                onChanged: (value) => _applyFilters(),
                controller: _convertedCurrencyController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildFilterTextField(
                label: 'Amount (Min)',
                icon: Icons.money,
                keyboardType: TextInputType.number,
                onChanged: (value) => _applyFilters(),
                controller: _amountController,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _clearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _baseCurrencyController.dispose();
    _convertedCurrencyController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}