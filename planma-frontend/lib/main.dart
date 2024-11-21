import 'package:flutter/material.dart';
import 'package:planma_app/core/dashboard.dart';
import 'package:provider/provider.dart';
import 'package:planma_app/authentication/log_in.dart';
import 'package:planma_app/Providers/time_provider.dart';
import 'package:planma_app/Providers/user_provider.dart';

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
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MaterialApp(
          //home: LogIn(),
          debugShowCheckedModeBanner: false,
          home: Dashboard(),
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
          )),
    );
  }
}
