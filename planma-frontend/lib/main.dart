import 'package:flutter/material.dart';
import 'package:planma_app/authentication/log_in.dart';
import 'package:planma_app/core/dashboard.dart';

import 'user_preferences/sleep_wake.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SleepWakeSetupScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
