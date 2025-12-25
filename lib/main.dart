import 'package:flutter/material.dart';
import 'login_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Home Devices",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF000000), // PURE BLACK
        cardColor: const Color(0xFF000000),
        primaryColor: const Color(0xFF415A77),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF415A77),
          secondary: Color(0xFF778DA9),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFE0E1DD)),
          bodyMedium: TextStyle(color: Color(0xFF778DA9)),
        ),
      ),
      home: const LoginPage(), // First Screen
    );
  }
}
