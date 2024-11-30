class Subject {
  final String subjectCode;
  final String subjectTitle;

  Subject({required this.subjectCode, required this.subjectTitle});

  // Factory constructor to parse JSON data
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectCode: json['subject_code'] ?? 'N/A',
      subjectTitle: json['subject_title'] ?? 'N/A',
    );
  }
}