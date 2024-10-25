import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currensee/Port/port.dart';

class ConversionsScreen extends StatefulWidget {
  const ConversionsScreen({super.key});

  @override
  State<ConversionsScreen> createState() => _ConversionsScreenState();
}

class _ConversionsScreenState extends State<ConversionsScreen> {
  String fromCurrency = "USD"; // Default currency to convert from
  String toCurrency = "EUR"; // Default currency to convert to
  double rate = 0.0; // Exchange rate
  double total = 0.0; // Total converted amount
  TextEditingController amountController = TextEditingController(); // Controller for the amount input
  List<String> currencies = []; // List of available currencies
  int? userId; // User ID for saving conversions

  @override
  void initState() {
    super.initState();
    _getCurrencies(); // Fetch available currencies on init
    _getUserId(); // Fetch user ID on init
  }

  // Function to save the conversion data
  Future<void> _saveConversion() async {
    if (userId == null || amountController.text.isEmpty) {
      // Handle empty user ID or amount error
      Fluttertoast.showToast(
        msg: "User ID or amount cannot be empty!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    // PHP endpoint to save conversion
    final url = '$port/save_conversion.php';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'user_id': userId.toString(),
        'from_currency': fromCurrency,
        'to_currency': toCurrency,
        'amount': amountController.text,
        'total': total.toString(),
        'conversion_date': DateTime.now().toString(),
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success'] == true) {
        Fluttertoast.showToast(
          msg: "Conversion saved successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Failed to save conversion!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Server error!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  // Function to convert the currency and save the conversion
  Future<void> _convertAndSave() async {
    if (amountController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter an amount!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    double amount = double.parse(amountController.text);
    setState(() {
      total = amount * rate; // Calculate total based on the input amount and rate
    });

    await _saveConversion(); // Save the conversion details after showing the total
  }

  // Function to get the user ID from shared preferences
  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id'); // Retrieve user ID
    });
  }

  // Function to fetch the list of available currencies
  Future<void> _getCurrencies() async {
    var response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));
    var data = json.decode(response.body);
    setState(() {
      currencies = (data['rates'] as Map<String, dynamic>).keys.toList(); // Store currency keys
      rate = data['rates'][toCurrency]; // Set initial rate based on default toCurrency
    });
  }

  // Function to fetch the conversion rate for the selected currencies
  Future<void> _getRate() async {
    var response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/$fromCurrency'));
    var data = json.decode(response.body);
    setState(() {
      rate = data['rates'][toCurrency]; // Update the rate for the selected toCurrency
    });
  }

  // Function to swap the selected currencies
  void _swapCurrencies() {
    setState(() {
      String temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp; // Swap currencies
      _getRate(); // Update rate after swapping
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21), // Background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          'Currency Converter', // App bar title
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(25),
                child: Image.asset(
                  'assets/logo.png', // Logo asset
                  width: MediaQuery.of(context).size.width / 4,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.white), // Input text color
                  decoration: InputDecoration(
                    labelText: "Amount", // Label for amount input
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelStyle: TextStyle(color: Colors.white), // Label color
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white), // Border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white), // Focused border color
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 100,
                      child: DropdownSearch<String>(
                        items: currencies,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "From", // Label for from currency dropdown
                            filled: true,
                            fillColor: Color(0xFF0A0E21),
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        popupProps: PopupProps.dialog(
                          showSearchBox: true,
                          dialogProps: DialogProps(
                            backgroundColor: Color(0xFF1d2630), // Background color of the popup dialog
                          ),
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black54, // Background color of the search box
                              labelText: 'Search Currency',
                              labelStyle: TextStyle(color: Colors.white), // Label text color
                              hintText: 'Type currency name...',
                              hintStyle: TextStyle(color: Colors.grey), // Hint text color
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white), // Border color of the search box
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white), // Enabled border color
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.greenAccent), // Focused border color
                              ),
                            ),
                            style: TextStyle(color: Colors.white), // Search text color
                            padding: EdgeInsets.all(20),
                          ),
                          itemBuilder: (context, item, isSelected) {
                            return ListTile(
                              title: Text(
                                item,
                                style: TextStyle(color: Colors.white), // Currency list item text color
                              ),
                            );
                          },
                        ),
                        dropdownBuilder: (context, selectedItem) {
                          return Text(
                            selectedItem ?? "", // Display selected currency
                            style: TextStyle(color: Colors.white), // Selected item color
                          );
                        },
                        selectedItem: fromCurrency,
                        onChanged: (newValue) {
                          setState(() {
                            fromCurrency = newValue!; // Update fromCurrency
                            _getRate(); // Get new rate when fromCurrency changes
                          });
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: _swapCurrencies, // Swap currencies when clicked
                      icon: Icon(
                        Icons.swap_horiz,
                        color: Colors.white, // Color of the swap icon
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: DropdownSearch<String>(
                        items: currencies,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "To", // Label for to currency dropdown
                            filled: true,
                            fillColor: Color(0xFF0A0E21),
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        popupProps: PopupProps.dialog(
                          showSearchBox: true,
                          dialogProps: DialogProps(
                            backgroundColor: Color(0xFF1d2630), // Background color of the popup dialog
                          ),
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black54, // Background color of the search box
                              labelText: 'Search Currency',
                              labelStyle: TextStyle(color: Colors.white), // Label text color
                              hintText: 'Type currency name...',
                              hintStyle: TextStyle(color: Colors.grey), // Hint text color
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white), // Border color of the search box
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white), // Enabled border color
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.greenAccent), // Focused border color
                              ),
                            ),
                            style: TextStyle(color: Colors.white), // Search text color
                            padding: EdgeInsets.all(20),
                          ),
                          itemBuilder: (context, item, isSelected) {
                            return ListTile(
                              title: Text(
                                item,
                                style: TextStyle(color: Colors.white), // Currency list item text color
                              ),
                            );
                          },
                        ),
                        dropdownBuilder: (context, selectedItem) {
                          return Text(
                            selectedItem ?? "", // Display selected currency
                            style: TextStyle(color: Colors.white), // Selected item color
                          );
                        },
                        selectedItem: toCurrency,
                        onChanged: (newValue) {
                          setState(() {
                            toCurrency = newValue!; // Update toCurrency
                            _getRate(); // Get new rate when toCurrency changes
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _convertAndSave, // Convert and save conversion on button press
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1d2630), // Button background color
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded button corners
                  ),
                ),
                child: Text(
                  'Convert', // Button text
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white, // Button text color
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (total > 0)
                Text(
                  'Total: ${total.toStringAsFixed(2)} $toCurrency', // Display total amount
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white, // Total text color
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
