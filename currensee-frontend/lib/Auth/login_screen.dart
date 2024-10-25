import "package:flutter/material.dart";
import 'package:currensee/Auth/register_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For parsing JSON
import 'package:currensee/Port/port.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:currensee/Admin/adminscreen.dart';
import 'package:currensee/UserScreens/mainscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currensee/Auth/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Create TextEditingController for email and password
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Function to handle login
  // Function to handle login
  Future<void> login() async {
  final email = emailController.text;
  final password = passwordController.text;

  if (email.isEmpty || password.isEmpty) {
    Fluttertoast.showToast(
      msg: "Please fill in both email and password.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    return;
  }

  print("Email : " + email);
  print("Password : " + password);

  final url = '$port/login.php';

  try {
    final response = await http.post(
      Uri.parse(url),
      body: {
        'email': email,
        'password': password,
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 && responseData['success']) {
      int role = responseData['role'];
      int userId = responseData['user_id'];

      // Print the user_id to console
      print("User ID: $userId");

      // Save login status using SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true); // Save login state
      await prefs.setInt('role', role); // Save role as an int
      await prefs.setInt('user_id', userId); // Save user_id as an int

      if (role == 0) {
        Fluttertoast.showToast(
          msg: "Login successful as User.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(),
          ),
        );
      } else if (role == 1) {
        Fluttertoast.showToast(
          msg: "Login successful as Admin.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminScreen(),
          ),
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Invalid email or password.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "An error occurred: $e",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    print("An error occurred: $e");
  }
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
                Icons.login,
                size: 80,
                color: Colors.tealAccent,
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                "Welcome Back",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Login to your account",
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
                      controller: emailController,
                      icon: Icons.email_outlined,
                      hintText: 'Email',
                    ),
                    const SizedBox(height: 20),

                    // Password Input Field
                    _buildTextField(
                      controller: passwordController,
                      icon: Icons.lock_outline,
                      hintText: 'Password',
                      obscureText: true,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen()),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.tealAccent,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Login Button
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
                        onPressed: login, // Call login function
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            "Login",
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

                    // "Or Continue with" text
                    const Center(
                      child: Text(
                        "Or Continue with",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Social Login Buttons (Facebook and Google)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          asset: 'assets/facebook.png',
                          label: "Facebook",
                          backgroundColor: const Color(0xFF484D6C),
                          onPressed: () {
                            // Facebook login logic
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildSocialButton(
                          asset: 'assets/google.png',
                          label: "Google",
                          backgroundColor: const Color(0xFF484D6C),
                          onPressed: () {
                            // Google login logic
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 45),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              color: Colors.tealAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

  // Social Button Widget
  Widget _buildSocialButton({
    required String asset,
    required String label,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Image.asset(
          asset,
          width: 20,
        ),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
