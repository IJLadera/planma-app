import 'dart:async';
import 'package:flutter/material.dart';
import 'package:planma_app/main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'lib/authentication/assets/planmalogo.png',
          width: 200,
          height: 200,
        ),
      ),
      backgroundColor: Color(0xFF173F70),
    );
  }
}
