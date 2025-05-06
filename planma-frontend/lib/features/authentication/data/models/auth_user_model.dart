import 'package:planma_app/features/authentication/domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser{
  AuthUserModel({
    required super.access,
    required super.refresh,
    required super.studentId,
  });

  // Covert app user to -> json
  Map<String, dynamic> toJson() {
    return {
      'refresh': refresh,
      'access': access,
      'student_id': studentId,
    };
  }

  // Convert json -> app user
  factory AuthUserModel.fromJson(Map<String, dynamic> jsonUser) {
    return AuthUserModel(
        refresh: jsonUser['refresh'],
        access: jsonUser['access'],
        studentId: jsonUser['student_id']);
  }
}
