import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planma/features/authentication/data/api_auth_repository.dart';
import 'package:planma/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:planma/features/splash/presentation/pages/splash_page.dart';

class MyApp extends StatelessWidget {
  // auth repository
  final apiAuthRepository = ApiAuthRepository();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          // auth cubit
          BlocProvider(
              create: (context) => AuthCubit(authRepository: apiAuthRepository)..checkAuth())
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashController(),
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
          ),
        ));
  }
}
