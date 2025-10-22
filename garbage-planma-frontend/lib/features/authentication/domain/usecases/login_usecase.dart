// lib/features/authentication/domain/usecases/login_usecase.dart

import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthUser?> execute(String email, String password) {
    return repository.loginWithEmailAndPassword(email, password);
  }
}
