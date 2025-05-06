import 'package:planma/features/authentication/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> loginWithEmailAndPassword(String email, String password);
  Future<AppUser?> getCurrentUser();
  Future<bool> checkAuth();
}
