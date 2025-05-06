import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:planma_app/authentication/auth_gate.dart';

// Note: You won't need this entire class anymore as the native splash
// will handle the initial splash screen display. This is just a
// transitional class to remove the splash and navigate to AuthGate.

class SplashController extends StatefulWidget {
  const SplashController({super.key});

  @override
  State<SplashController> createState() => _SplashControllerState();
}

class _SplashControllerState extends State<SplashController> {
  @override
  void initState() {
    super.initState();

    // Remove the splash screen when app is ready
    initialization();
  }

  void initialization() async {
    // Delay just a bit to ensure smooth transition
    await Future.delayed(const Duration(milliseconds: 2000));

    // Remove the native splash screen
    FlutterNativeSplash.remove();

    // Navigate to your main screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // This build method won't be seen by users as native splash
    // is handling the splash display
    return const Scaffold(
      backgroundColor: Color(0xFF173F70),
      body: SizedBox.shrink(),
    );
  }
}
