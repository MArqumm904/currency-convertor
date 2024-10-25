import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:currensee/Auth/login_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:currensee/Port/port.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> registerUser() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    print("Name: $name");
    print("Email: $email");
    print("Password: $password");

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill in all fields");
      return;
    }

    try {
      var url = Uri.parse(
        '$port/register.php'); // Ensure this line is correct
      var response = await http.post(url, body: {
        'name': name,
        'email': email,
        'password': password,
      });

      // Check the response
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["success"] == true) {
          Fluttertoast.showToast(msg: "Registration successful!");
          // Navigate to the login screen or home screen after success
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          Fluttertoast.showToast(
              msg: "Registration failed! ${data["message"]}");
        }
      } else {
        Fluttertoast.showToast(
            msg:
                "Failed to connect to server. Status code: ${response.statusCode}");
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "An error occurred: $error");
      print("Error : $error");
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
              const SizedBox(height: 70), // Optional padding from the top

              // Logo
              const Icon(
                Icons.currency_exchange, // Replace with the actual logo
                size: 80,
                color: Colors.tealAccent,
              ),
              const SizedBox(height: 20),

              // Title and Subtitle
              const Text(
                "Get Started",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Let's create your account",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),

              // Rounded Container that holds the form fields and button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1D1F33), // Background color for form area
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Input Field
                    _buildTextField(
                      icon: Icons.person_outline,
                      hintText: 'Name',
                      controller: nameController,
                    ),
                    const SizedBox(height: 20),

                    // Email Input Field
                    _buildTextField(
                      icon: Icons.email_outlined,
                      hintText: 'Email',
                      controller: emailController,
                    ),
                    const SizedBox(height: 20),

                    // Password Input Field
                    _buildTextField(
                      icon: Icons.lock_outline,
                      hintText: 'Password',
                      obscureText: true,
                      controller: passwordController,
                    ),
                    const SizedBox(
                        height: 40), // Padding between fields and button

                    // Get Started Button
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
                        onPressed: () {
                          registerUser();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            "SignUp",
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
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "have an account?",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to login screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.tealAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ), // Bottom padding
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
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
        filled: false, // No background color
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
