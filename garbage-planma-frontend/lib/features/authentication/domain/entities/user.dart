class User {
  final String firstName;
  final String lastName;
  final String username;
  final String studentId;
  final String email;

  User(
      {required this.firstName,
      required this.lastName,
      required this.username,
      required this.studentId,
      required this.email});

  // Convert user to -> json
  Map<String, dynamic> toJson() {
    return {
      'firstname': firstName,
      "lastname": lastName,
      "username": username,
      "student_id": studentId,
      "email": email
    };
  }

  // Convert json -> app user
  factory User.fromJson(Map<String, dynamic> jsonUser) {
    return User(
        firstName: jsonUser['firstname'],
        lastName: jsonUser['lastname'],
        username: jsonUser['username'],
        studentId: jsonUser['student_id'],
        email: jsonUser['email']);
  }
}
