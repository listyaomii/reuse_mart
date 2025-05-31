import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reuse_mart/View/homePage.dart';
import 'package:reuse_mart/View/hunterHome.dart';
import 'package:reuse_mart/View/kurirHome.dart';
import 'package:reuse_mart/View/pembeliHome.dart';
import 'package:reuse_mart/View/penitipHome.dart';

void main() {
  runApp(const ProviderScope(child: MainApp())); // Wrapping with ProviderScope
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reusemart',
      home: HomePage(), // Changed to use class name with uppercase
    );
  }
}
