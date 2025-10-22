import 'package:flutter/material.dart';
import 'package:planma_app/Providers/userprof_provider.dart';
import 'package:planma_app/Providers/web_socket_provider.dart';
import 'package:planma_app/core/dashboard.dart';
import 'package:planma_app/features/authentication/presentation/pages/log_in_page.dart';
import 'package:planma_app/features/authentication/presentation/providers/user_provider.dart';
import 'package:planma_app/reminder/reminder_listener.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Load Provider
  Future<void> _loadProviders(
      {required BuildContext context,
      required List<Function> initFunctions}) async {
    for (Function func in initFunctions) {
      if (func is Future<dynamic> Function()) {
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

  // Check if the user is authenticated
  Future<bool> _authCheck() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final webSocketProvider =
        Provider.of<WebSocketProvider>(context, listen: false);

    bool isAuth = await userProvider.checkAuthentication();

    // Initialize WebSocket if authenticated
    if (isAuth) {
      webSocketProvider.onUserAuthenticated();
    }

    return isAuth;
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
  
                    return ReminderListener(child: Dashboard());
                  });
            } else {
              return LogInPage();
            }
          }

          return const Center(
            child: Text('AuthGate._authCheck has returned null value.'),
          );
        });
  }
}
