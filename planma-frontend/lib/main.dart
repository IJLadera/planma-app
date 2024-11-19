import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:planma_app/authentication/log_in.dart';
import 'package:planma_app/Providers/time_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimeProvider()),
      ],
      child: MaterialApp(
        home: const LogIn(), // Login serves as the entry point
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.blue[50],
        ),
      ),
    );
  }
}
