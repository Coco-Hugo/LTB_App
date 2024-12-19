import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:ltb_app/screens/login_screen.dart';
import 'package:ltb_app/widgets/navbar.dart';
import 'firebase_options.dart'; // Firebase config if you're using Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Kakao SDK with your native app key
  KakaoSdk.init(
    nativeAppKey:
        '5b8169445e0f6b9655768cb6383947aa', // Replace with your Kakao app's native key
  );

  // Initialize Firebase (if required)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF181818),
          primarySwatch: Colors.indigo),
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const MainScreen(), // Define your home screen
      },
    );
  }
}
