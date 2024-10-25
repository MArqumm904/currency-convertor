import 'dart:async';
import 'package:currensee/Auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currensee/Admin/adminscreen.dart';
import 'package:currensee/UserScreens/mainscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _loaderController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

    // Start the fade-in animation only once
    _fadeController.forward();

    // Start and repeat the loader animation
    _loaderController.repeat();

    // Navigate to login page after a delay
    Timer(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final userRole = prefs.getInt('role'); // Retrieve role as an int

      // Navigate to the appropriate screen based on login status and role
      if (isLoggedIn) {
        if (userRole == 1) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminScreen()),
          );
        } else if (userRole == 0) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  Widget _buildBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildDot() {
    return AnimatedBuilder(
      animation: _loaderController,
      builder: (context, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(_loaderController.value),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDot({double delay = 0.0}) {
    return AnimatedBuilder(
      animation: _loaderController,
      builder: (context, child) {
        return Opacity(
          opacity:
              (((_loaderController.value + delay) % 1.0) < 0.5) ? 1.0 : 0.3,
          child: _buildDot(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xFF1C213F), // Dark blue background color
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: BubblePainter(),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: _buildBubble(30, Colors.white.withOpacity(0.1)),
          ),
          Positioned(
            bottom: 60,
            right: 30,
            child: _buildBubble(40, Colors.white.withOpacity(0.15)),
          ),
          Positioned(
            top: 120,
            right: 50,
            child: _buildBubble(20, Colors.white.withOpacity(0.08)),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 90,
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1F2937),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'CurrenSee',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Currency Converter App',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 80), // Increased space before loader
                  SizedBox(
                    width: 200,
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedDot(),
                        const SizedBox(width: 10),
                        _buildAnimatedDot(delay: 0.2),
                        const SizedBox(width: 10),
                        _buildAnimatedDot(delay: 0.4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add this class at the end of the file
class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F2543)
      ..style = PaintingStyle.fill;

    // Draw multiple bubbles
    _drawBubble(canvas, paint, size.width * 0.2, size.height * 0.3, 40);
    _drawBubble(canvas, paint, size.width * 0.8, size.height * 0.2, 60);
    _drawBubble(canvas, paint, size.width * 0.5, size.height * 0.7, 50);
    _drawBubble(canvas, paint, size.width * 0.1, size.height * 0.8, 30);
  }

  void _drawBubble(
      Canvas canvas, Paint paint, double x, double y, double radius) {
    canvas.drawCircle(Offset(x, y), radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
