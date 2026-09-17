import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const StackyApp());
}

class StackyApp extends StatelessWidget {
  const StackyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stacky',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C63FF),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
