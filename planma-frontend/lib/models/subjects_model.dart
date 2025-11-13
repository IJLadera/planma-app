class Subject {
  final int subjectId;
  final String subjectCode;
  final String subjectTitle;
  final int semesterId;
  final int? prerequisiteSubjectId; // nullable if no prerequisite
  final bool isUnlocked; // true if already unlocked/completed

  Subject({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectTitle,
    required this.semesterId,
    this.prerequisiteSubjectId,
    this.isUnlocked = false,
  });

  // Factory constructor to parse JSON data
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['subject_id'] ?? 0,
      subjectCode: json['subject_code'] ?? 'N/A',
      subjectTitle: json['subject_title'] ?? 'N/A',
      semesterId: json['semester_id'] is int
          ? json['semester_id']
          : (json['semester_id']?['semester_id'] ?? 0),
      prerequisiteSubjectId: json['prerequisite_subject_id'],
      isUnlocked: json['is_unlocked'] ?? false,
    );
  }
}
