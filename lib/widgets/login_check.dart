import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ltb_app/screens/home_screen.dart';
import 'package:ltb_app/screens/login_screen.dart';

class LoginCheck extends StatelessWidget {
  const LoginCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          // User is logged in
          return const HomeScreen();
        } else {
          // User is not logged in
          return const LoginScreen();
        }
      },
    );
  }
}
