import 'package:currensee/Port/port.dart';
import 'package:currensee/UserScreens/currencies.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> currencies = [];

  int? userId;
  String userName = "";

  @override
  void initState() {
    super.initState();
    _getUserId();
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    final response = await http
        .get(Uri.parse("https://api.exchangerate-api.com/v4/latest/USD"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rates = data['rates'] as Map<String, dynamic>;

      setState(() {
        // Limit to the first 10 currencies
        currencies = rates.entries.take(10).map((entry) {
          return {
            "symbol": entry.key, // Currency symbol
            "value": "\$${entry.value.toStringAsFixed(2)}" // Formatted value
          };
        }).toList();
      });
    } else {
      // Handle error
      print("Failed to fetch currencies");
    }
  }

  Widget _buildCurrencyList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currencies.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        final currency = currencies[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.tealAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.currency_bitcoin,
                  color: Colors.tealAccent), // Placeholder icon
            ),
            title: Text(
              currency["symbol"]!, // Use the symbol from the API
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              currency["symbol"]!, // Displaying symbol as subtitle
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            trailing: Text(
              currency["value"]!, // Displaying the formatted value
              style: const TextStyle(
                color: Colors.tealAccent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });

    if (userId != null) {
      _fetchUserName(userId!);
    }
  }

  Future<void> _fetchUserName(int userId) async {
    try {
      final url = Uri.parse('$port/getname.php');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            userName = data['name'];
            print(data['name']);
          });
        } else {
          // Handle error if user not found
          print(data['message']);
        }
      } else {
        // Handle server error
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      // Handle network error
      print("Error: $e");
    }
  }

  // Sample data for charts
  final List<FlSpot> ethereumSpots = [
    FlSpot(0, 1),
    FlSpot(1, 1.5),
    FlSpot(2, 1.4),
    FlSpot(3, 2),
    FlSpot(4, 1.8),
    FlSpot(5, 2.6),
  ];

  final List<FlSpot> bitcoinSpots = [
    FlSpot(0, 1.5),
    FlSpot(1, 1.2),
    FlSpot(2, 1.8),
    FlSpot(3, 1.4),
    FlSpot(4, 1.6),
    FlSpot(5, 1.3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17171F),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildGreeting(),
              _buildMarketActivity(),
              _buildTransactions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Home",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              icon:
                  const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello, $userName 👋",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Good morning, spread positivity\nto everyone",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "International Currency Activity",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 240, // Increased height to prevent overflow
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildCryptoCard(
                "USD Dollars",
                "USD",
                Colors.purple,
                8291.00,
                2.6,
                "14,582.00",
                ethereumSpots,
              ),
              _buildCryptoCard(
                "quwat e dinar",
                "KWD",
                Colors.teal,
                8291.00,
                -1.4,
                "13,582.00",
                bitcoinSpots,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCryptoCard(String name, String symbol, Color color,
      double balance, double change, String profit, List<FlSpot> spots) {
    return Container(
      width: 280,
      height: 220, // Fixed total height
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16), // Reduced padding from 20 to 16
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Coin name and symbol in a more compact layout
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Reduced from 20
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        symbol,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13, // Reduced from 14
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // Reduced from 16

            // Chart with adjusted height
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 5,
                  minY: 0,
                  maxY: 3,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.white,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12), // Reduced from 16

            // Bottom row with price info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$$balance",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18, // Reduced from 20
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          change > 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: change > 0 ? Colors.green : Colors.red,
                          size: 14, // Reduced from 16
                        ),
                        const SizedBox(width: 2), // Reduced from 4
                        Text(
                          "${change.abs()}%",
                          style: TextStyle(
                            color: change > 0 ? Colors.green : Colors.red,
                            fontSize: 13, // Reduced from 14
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "\$$profit",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13, // Reduced from 14
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Trending Currencies",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CurrenciesPage()),
                  );
                },
                child: const Text(
                  "View All",
                  style: TextStyle(color: Colors.tealAccent),
                ),
              ),
            ],
          ),
        ),
        _buildCurrencyList(),
      ],
    );
  }

  // Widget _buildCurrencyList() {
  //   final currencies = [
  //     {"name": "Bitcoin", "symbol": "BTC", "value": "\$5,770.50"},
  //     {"name": "Ethereum", "symbol": "ETH", "value": "\$4,770.50"},
  //     {"name": "Ripple", "symbol": "XRP", "value": "\$3,790.50"},
  //     {"name": "Litecoin", "symbol": "LTC", "value": "\$2,270.50"},
  //     {"name": "Bitcoin Cash", "symbol": "BCH", "value": "\$5,770.50"},
  //   ];

  //   return ListView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     itemCount: currencies.length,
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     itemBuilder: (context, index) {
  //       final currency = currencies[index];
  //       return Container(
  //         margin: const EdgeInsets.only(bottom: 12),
  //         decoration: BoxDecoration(
  //           color: Colors.white.withOpacity(0.05),
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         child: ListTile(
  //           contentPadding: const EdgeInsets.all(12),
  //           leading: Container(
  //             width: 50,
  //             height: 50,
  //             decoration: BoxDecoration(
  //               color: Colors.tealAccent.withOpacity(0.2),
  //               borderRadius: BorderRadius.circular(15),
  //             ),
  //             child: const Icon(Icons.currency_bitcoin, color: Colors.tealAccent),
  //           ),
  //           title: Text(
  //             currency["name"]!,
  //             style: const TextStyle(
  //               color: Colors.white,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //           subtitle: Text(
  //             currency["symbol"]!,
  //             style: TextStyle(color: Colors.white.withOpacity(0.7)),
  //           ),
  //           trailing: Text(
  //             currency["value"]!,
  //             style: const TextStyle(
  //               color: Colors.tealAccent,
  //               fontSize: 16,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
