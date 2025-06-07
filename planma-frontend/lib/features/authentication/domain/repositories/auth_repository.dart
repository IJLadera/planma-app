import 'package:planma_app/features/authentication/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser?> loginWithEmailAndPassword(String email, String password);
  Future<void> checkAndStoreCurrentUser();
}
