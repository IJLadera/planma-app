import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planma/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:planma/features/authentication/presentation/cubits/auth_states.dart';
import 'package:planma/features/authentication/presentation/pages/login_page.dart';
import 'package:planma/features/dashboard/presentation/pages/dashboard_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(builder: (context, authStates) {
      // unauthenticated -> login page
      if (authStates is Unauthenticated) {
        return LoginPage();
      }

      // authenticated -> dashboard page
      else if (authStates is Authenticated) {
        return DashboardPage();
      }

      // loading
      else {
        return const Center(child: CircularProgressIndicator());
      }
    }, listener: (context, authState) {
      if (authState is AuthError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(authState.message)));
      }
    });
  }
}
