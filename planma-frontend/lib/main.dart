import 'package:flutter/material.dart';
import 'package:planma_app/authentication/log_in.dart';
import 'package:planma_app/core/dashboard.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Dashboard(username: "jian"),
      debugShowCheckedModeBanner: false,
    );
  }
}
