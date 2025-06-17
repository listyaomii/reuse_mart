import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:reuse_mart/View/homePage.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> with TickerProviderStateMixin {
  void _goToHomePage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  final pageDecoration = PageDecoration(
    titleTextStyle: TextStyle(
        fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black),
    bodyTextStyle: TextStyle(fontSize: 16.0, color: Colors.black87),
    bodyPadding: EdgeInsets.all(16.0),
    imagePadding: EdgeInsets.only(top: 300),
    pageColor: Color(0xFFD5BD96), // warna coklat muda sesuai homepage
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "Selamat Datang di ReuseMart",
            body: "Temukan produk ramah lingkungan dengan mudah!",
            image: Align(
              alignment: Alignment.topCenter,
              child: Icon(
                Icons.eco,
                size: 120,
                color: Color(0xFF3E4C2C),
              ),
            ),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Belanja & Daur Ulang",
            body: "Dukung bumi dengan membeli barang bekas berkualitas.",
            image: Align(
              alignment: Alignment.topCenter,
              child: Icon(
                Icons.recycling,
                size: 120,
                color: Color(0xFF3E4C2C),
              ),
            ),
            decoration: pageDecoration,
          ),
        ],
        onDone: _goToHomePage,
        onSkip: _goToHomePage,
        showSkipButton: true,
        skip: const Text("Lewati", style: TextStyle(color: Color(0xFF3E4C2C))),
        next: const Icon(Icons.arrow_forward, color: Color(0xFF3E4C2C)),
        done: const Text("Selesai",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF3E4C2C))),
        dotsDecorator: DotsDecorator(
          size: Size(10.0, 10.0),
          color: Colors.grey,
          activeColor: Color(0xFF3E4C2C),
          activeSize: Size(22.0, 10.0),
          activeShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        ),
      ),
    );
  }
}
