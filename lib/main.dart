import 'package:flutter/material.dart';
// 1. Import your new HomeScreen
import 'features/home/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'NekoPaper Mobile',
      // TODO:
      debugShowCheckedModeBanner: true,
      // 2. Setting up a theme that matches your Vue site's "dark & cyan" vibe
      // TODO:
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.cyanAccent,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D), // Background-dark
      ),
      // 3. Point 'home' to your new HomeScreen widget
      home: HomeScreen(),
    );
  }
}
