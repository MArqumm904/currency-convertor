import 'package:currensee/Auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http; // Add this import for HTTP requests
import 'package:currensee/Port/port.dart';
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter your email",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    // Make HTTP request to your PHP backend to check if the email is valid
    try {
      final response = await http.post(
        Uri.parse('$port/check_email.php'), // Replace with your PHP URL
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        var jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'valid') {
          // Email is valid, show dialog to enter new password
          _showNewPasswordDialog(email);
        } else if (jsonResponse['status'] == 'invalid') {
          Fluttertoast.showToast(
            msg: "Email is not registered",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        } else if (jsonResponse['status'] == 'no_email') {
          Fluttertoast.showToast(
            msg: "No email provided",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Failed to check email",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  void _showNewPasswordDialog(String email) {
    TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
          ),
          title: const Text(
            'Enter New Password',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue, // Add custom color to title
            ),
            textAlign: TextAlign.center, // Center title text
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please enter your new password below.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey, // Add subtitle styling
                ),
                textAlign: TextAlign.center, // Center subtitle
              ),
              const SizedBox(height: 20), // Space between subtitle and input
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'New Password',
                  filled: true,
                  fillColor:
                      Colors.grey[200], // Light background for input field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded input
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ), // Padding inside the input field
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green, // Set button color (use backgroundColor)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded button
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ), // Button padding
                  ),
                  onPressed: () async {
                    // Send new password to backend
                    String newPassword = newPasswordController.text.trim();
                    if (newPassword.isNotEmpty) {
                      // Make HTTP request to update the password in your PHP backend
                      try {
                        final response = await http.post(
                          Uri.parse(
                              '$port/update_password.php'), // Replace with your PHP URL
                          body: {
                            'email': email,
                            'new_password': newPassword,
                          },
                        );

                        if (response.statusCode == 200) {
                          Fluttertoast.showToast(
                            msg: "Password updated successfully!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                          );
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          ); // Close the dialog
                        } else {
                          Fluttertoast.showToast(
                            msg: "Failed to update password",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                        }
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: "An error occurred",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                      }
                    } else {
                      Fluttertoast.showToast(
                        msg: "Please enter a new password",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    }
                  },
                  child: const Text(
                    'Update',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red, // Set button color (use backgroundColor)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded button
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ), // Button padding
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Space below the buttons
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21), // Dark background color
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 50), // Optional padding from the top

              // Logo
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.tealAccent,
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                "Reset Your Password",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Enter your email to reset password",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),

              // Rounded Container for form fields and button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1D1F33),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),

                    // Email Input Field
                    _buildTextField(
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      hintText: 'Email',
                    ),
                    const SizedBox(height: 20),

                    const SizedBox(height: 40),

                    // Reset Password Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00FFDA), Color(0xFF00C8FF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Text(
                                  "Email Check",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Back to Login Link
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Go back to login
                        },
                        child: const Text(
                          "Back to Login",
                          style: TextStyle(
                            color: Colors.tealAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Text Field Widget with Icon and Underline Style
  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white54),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.tealAccent),
        ),
      ),
    );
  }
}
