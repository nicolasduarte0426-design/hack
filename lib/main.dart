import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ShadowNetApp());
}

class ShadowNetApp extends StatelessWidget {
  const ShadowNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShadowNet',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const LoginScreen(),
    );
  }
}