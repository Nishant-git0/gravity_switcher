import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';

void main() {
  runApp(const GravitySwitcherApp());
}

class GravitySwitcherApp extends StatelessWidget {
  const GravitySwitcherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gravity Switcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}
