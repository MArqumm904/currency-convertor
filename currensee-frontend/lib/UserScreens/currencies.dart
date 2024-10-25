import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrenciesPage extends StatefulWidget {
  @override
  _CurrenciesPageState createState() => _CurrenciesPageState();
}

class _CurrenciesPageState extends State<CurrenciesPage> {
  List<Map<String, dynamic>> currencies = [];
  List<Map<String, dynamic>> filteredCurrencies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    final response = await http.get(Uri.parse("https://api.exchangerate-api.com/v4/latest/USD"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rates = data['rates'] as Map<String, dynamic>;

      setState(() {
        currencies = rates.entries.map((entry) {
          return {
            "symbol": entry.key,
            "value": entry.value.toStringAsFixed(2),
          };
        }).toList();
        filteredCurrencies = currencies;
        isLoading = false;
      });
    } else {
      print("Failed to fetch currencies");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterCurrencies(String query) {
    final filtered = currencies.where((currency) {
      final symbol = currency['symbol'].toLowerCase();
      return symbol.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredCurrencies = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17171F),
      appBar: AppBar(
        backgroundColor: Colors.tealAccent,
        elevation: 0,
        title: const Text(
          "Currencies",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchCurrencies,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    onChanged: _filterCurrencies,
                    decoration: InputDecoration(
                      hintText: 'Search currency...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Colors.tealAccent),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = filteredCurrencies[index];
                      return Card(
                        color: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.tealAccent,
                            child: const Icon(Icons.monetization_on, color: Colors.black),
                          ),
                          title: Text(
                            currency['symbol'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            "Exchange Rate",
                            style: const TextStyle(color: Colors.white54),
                          ),
                          trailing: Text(
                            "\$${currency['value']}",
                            style: const TextStyle(
                              color: Colors.tealAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
