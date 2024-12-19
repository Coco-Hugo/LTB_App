import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ltb_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PageController _pageController = PageController();
  late Timer _timer;
  int _currentPage = 0;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    // Start auto-scrolling for the PageView
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < 2) {
        // cycle through slides (0,1,2)
        _currentPage++;
      } else {
        _currentPage = 0; // Reset to the first page
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loginWithKakao(BuildContext context) async {
    try {
      // signInWithKakao should:
      // 1. Retrieve Kakao user ID & other info.
      // 2. Call Firebase Function createCustomToken with uid.
      // 3. Sign in to Firebase using the custom token.
      // 4. Return a Firebase User if successful.
      final user = await _authService.signInWithKakao();

      if (user != null) {
        // Firebase login was successful, navigate to home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // If user is null, something went wrong in signInWithKakao().
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed: No user returned")),
        );
      }
    } catch (error) {
      print("Login failed: $error");

      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceH = MediaQuery.of(context).size.height;
    const double sliderH = 600;
    const double pullup = -100; // Moved const definition for clarity

    return Scaffold(
      body: Stack(
        children: [
          // Top slider
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: sliderH,
            child: PageView(
              controller: _pageController,
              children: [
                Image.asset(
                  'assets/login_slider/slider1.jpg',
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  'assets/login_slider/slider2.jpg',
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  'assets/login_slider/slider3.jpg',
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
          // Bottom container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: deviceH - sliderH - pullup,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff000080),
                borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/brand/ltb_logo_transparent.png',
                    height: 180,
                  ),
                  ElevatedButton(
                    onPressed: () => _loginWithKakao(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFEE500),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 45,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/kakao_btn.png',
                          height: 30,
                          width: 30,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Start with Kakao",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: Color(0xff181818),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
