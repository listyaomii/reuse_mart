import 'package:flutter/material.dart';

class Informasiumum extends StatelessWidget {
  const Informasiumum({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // Tetap mempertahankan MaterialApp seperti permintaan
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFCFBB99),
        body: Center(
          child: Text(
            'reuseMart', // Perbaiki kesalahan ketik dari 'reuseMasrt'
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ), 
    );
  }
}