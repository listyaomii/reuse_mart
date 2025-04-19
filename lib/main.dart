import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reuse_mart/View/homePage.dart';

void main() {
  runApp(const ProviderScope(child: MainApp())); // Wrapping with ProviderScope
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atma Salon',
      home: HomePage(), // Changed to use class name with uppercase
    );
  }
}
