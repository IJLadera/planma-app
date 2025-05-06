// Auth States
import 'package:planma/features/authentication/domain/entities/app_user.dart';

abstract class AuthStates {}

// Initial
class AuthInitial extends AuthStates {}

// Loading...
class AuthLoading extends AuthStates {}

// Authenticated
class Authenticated extends AuthStates {
  final AppUser user;
  Authenticated(this.user);
}

// Unauthenticated
class Unauthenticated extends AuthStates {}

// Errors
class AuthError extends AuthStates {
  final String message;
  AuthError(this.message);
}
