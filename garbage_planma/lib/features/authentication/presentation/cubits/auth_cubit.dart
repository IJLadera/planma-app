import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planma/features/authentication/domain/repositories/auth_repository.dart';
import 'package:planma/features/authentication/presentation/cubits/auth_states.dart'; // Make sure you import this

// Auth Cubit: State Management
class AuthCubit extends Cubit<AuthStates> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial()) {
    checkAuth();
  }

  // Check authentication status
  Future<void> checkAuth() async {
    emit(AuthLoading()); // Emit loading state
    try {
      bool isAuthenticated = await authRepository.checkAuth();
      if (isAuthenticated) {
        final user = await authRepository.getCurrentUser();
        emit(Authenticated(user!)); // Emit authenticated state
      } else {
        emit(Unauthenticated()); // Emit unauthenticated state
      }
    } catch (e) {
      emit(AuthError('Failed to check authentication: $e')); // Emit error state
    }
  }

  // Login with email and password
  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());

      final user =
          await authRepository.loginWithEmailAndPassword(email, password);

      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }
}
