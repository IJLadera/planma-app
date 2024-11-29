import 'package:flutter/material.dart';
import 'package:planma_app/Providers/class_schedule_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/Providers/userprof_provider.dart';
import 'package:planma_app/core/dashboard.dart';
import 'package:provider/provider.dart';
import 'package:planma_app/authentication/log_in.dart';
import 'package:planma_app/Providers/time_provider.dart';
import 'package:planma_app/Providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:planma_app/Providers/events_provider.dart';

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
        ChangeNotifierProvider(create: (context) => UserProfileProvider()),
        ChangeNotifierProvider(create: (context) => SemesterProvider()),
        ChangeNotifierProvider(create: (context) => ClassScheduleProvider()),
        ChangeNotifierProvider(create: (context) => EventsProvider()),
      ],
      child: MaterialApp(
          // home: Dashboard(),
          debugShowCheckedModeBanner: false,
          home: AuthGate(),
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
          )),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<void> _loadProviders(
      {required BuildContext context,
      required List<Function> initFunctions}) async {
    for (Function func in initFunctions) {
      if (func is Future<dynamic> Function()) {
        print(func.toString());
        await func();
      } else if (func is Future<dynamic> Function(BuildContext)) {
        if (context.mounted) {
          await func(context);
        }
      } else {
        func();
      }
    }
    return;
  }

  Future<bool> _authCheck() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? accessToken = sharedPreferences.getString("access");
    String? refreshToken = sharedPreferences.getString("refresh");

    if (accessToken == null && refreshToken == null) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _authCheck(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            if (snapshot.data!) {
              return FutureBuilder(
                  future: _loadProviders(context: context, initFunctions: [
                    context.read<UserProfileProvider>().init,
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Dashboard();
                  });
            } else {
              return LogIn();
            }
          }
          return const Center(
            child: Text('AuthorPage._authCheck has returned null value.'),
          );
        });
  }
}
