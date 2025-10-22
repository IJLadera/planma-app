class Subject {
  final int subjectId;
  final String subjectCode;
  final String subjectTitle;
  final int semesterId;

  Subject({
    required this.subjectId,
    required this.subjectCode, 
    required this.subjectTitle,
    required this.semesterId,
  });

  // Factory constructor to parse JSON data
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['subject_id'] ?? 0,
      subjectCode: json['subject_code'] ?? 'N/A',
      subjectTitle: json['subject_title'] ?? 'N/A',
      semesterId: json['semester_id'] != null
        ? json['semester_id']['semester_id'] ?? 0
        : 0, // Extract the semester_id if it's present, otherwise default to 0
    );
  }
}