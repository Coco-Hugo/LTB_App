import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _loginWithKakao(BuildContext context) async {
    try {
      // Check if KakaoTalk app is installed
      bool kakaoTalkInstalled = await isKakaoTalkInstalled();

      // Attempt to log in using KakaoTalk app or fallback to web login
      OAuthToken token = kakaoTalkInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      print("Kakao login successful! Token: ${token.accessToken}");

      // Navigate to the home screen
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      print("Kakao login failed: $error");

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Login",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _loginWithKakao(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                textStyle: const TextStyle(color: Colors.black),
              ),
              child: const Text("Login with Kakao"),
            ),
          ],
        ),
      ),
    );
  }
}
