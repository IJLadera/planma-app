class AppUser {
  final String refresh;
  final String access;
  final String studentId;

  AppUser(
      {required this.refresh, required this.access, required this.studentId});

  // Covert app user to -> json
  Map<String, dynamic> toJson() {
    return {
      'refresh': refresh,
      'access': access,
      'student_id': studentId,
    };
  }

  // Convert json -> app user
  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
        refresh: jsonUser['refresh'],
        access: jsonUser['access'],
        studentId: jsonUser['student_id']);
  }
}
