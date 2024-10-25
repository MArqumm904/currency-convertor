import 'package:currensee/Admin/adminscreen.dart';
import 'package:currensee/Port/port.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
 // Replace with your server URL

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  List<Map<String, dynamic>> _users = [];
  String _searchQuery = '';
  int _currentIndex = 0;

  Future<void> _fetchUsers() async {
    try {
      final url = Uri.parse('$port/getUsers.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success']) {
          setState(() {
            _users = List<Map<String, dynamic>>.from(data['users'].map((user) {
              user['id'] = int.tryParse(user['id'].toString()) ?? 0;
              return user;
            }));
          });
        } else {
          print("Error: ${data['message']}");
        }
      } else {
        print("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("Network error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }
    return _users.where((user) {
      return user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['email'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _addUser() {
    print("Add User");
  }

 void _editUser(int id, String name, String email) {
  showDialog(
    context: context,
    builder: (context) {
      final TextEditingController nameController = TextEditingController(text: name);
      final TextEditingController emailController = TextEditingController(text: email);
      final TextEditingController passwordController = TextEditingController(); // New Password Controller

      return AlertDialog(
        title: const Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController, // Password TextField
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true, // To hide password input
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _updateUser(id, nameController.text, emailController.text, passwordController.text); // Pass the password
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}

  void _updateUser(int id, String name, String email, String password) async {
  try {
    final url = Uri.parse('$port/updateadminUser.php');
    final response = await http.post(url, body: {
      'id': id.toString(),
      'name': name,
      'email': email,
      'password': password, // Include password in the request
    });

    final data = jsonDecode(response.body);
    print("Response from server: ${response.body}"); // Debugging line

    if (data['success']) {
      setState(() {
        final index = _users.indexWhere((user) => user['id'].toString() == id.toString());
        if (index != -1) {
          _users[index]['name'] = name;
          _users[index]['email'] = email;
        }
      });
      print(data['message']);
    } else {
      print("Error: ${data['message']}");
    }
  } catch (e) {
    print("Network error: $e");
  }
}



  void _deleteUser(int id) async {
    try {
      final url = Uri.parse('$port/deleteUser.php');
      final response = await http.post(url, body: {
        'id': id.toString(),
      });

      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          _users.removeWhere((user) => user['id'].toString() == id.toString());
        });
        print(data['message']);
      } else {
        print("Error: ${data['message']}");
      }
    } catch (e) {
      print("Network error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Management',
          style: TextStyle(color: Colors.white54),
        ),
        backgroundColor: const Color(0xFF0A0E21),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
           onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminScreen()), // Navigate to AdminScreen
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addUser,
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF0A0E21),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Users Management',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white54),
              decoration: InputDecoration(
                labelText: 'Search by Name or Email',
                labelStyle: const TextStyle(color: Colors.white54),
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.search, color: Colors.white54),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID', style: TextStyle(color: Colors.white54))),
                      DataColumn(label: Text('Name', style: TextStyle(color: Colors.white54))),
                      DataColumn(label: Text('Email', style: TextStyle(color: Colors.white54))),
                      DataColumn(label: Text('Actions', style: TextStyle(color: Colors.white54))),
                    ],
                    rows: _filteredUsers.map((user) {
                      return DataRow(cells: [
                        DataCell(Text(user['id'].toString(), style: const TextStyle(color: Colors.white54))),
                        DataCell(Text(user['name'], style: const TextStyle(color: Colors.white54))),
                        DataCell(Text(user['email'], style: const TextStyle(color: Colors.white54))),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.tealAccent),
                                onPressed: () => _editUser(user['id'], user['name'], user['email']),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.tealAccent),
                                onPressed: () => _deleteUser(user['id']),
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0A0E21),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Conversions'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Currencies'),
          BottomNavigationBarItem(icon: Icon(Icons.miscellaneous_services), label: 'Services'),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.white54,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Users(),
  ));
}
