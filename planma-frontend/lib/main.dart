import 'package:flutter/material.dart';
import 'package:planma_app/Providers/user_provider.dart';
import 'package:planma_app/authentication/log_in.dart';
import 'package:planma_app/core/dashboard.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()
        )
      ],
      child: MaterialApp(
        home: LogIn(),
          //home: Dashboard (username: 'jian),
      )
    );    
  }
}
