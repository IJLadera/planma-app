class ScheduleEntry {
  final String entryId;
  final String categoryType;
  final int referenceId;
  final String studentId;
  final DateTime scheduledDate;
  final String scheduledStartTime;
  final String scheduledEndTime;

  ScheduleEntry({
    required this.entryId,
    required this.categoryType,
    required this.referenceId,
    required this.studentId,
    required this.scheduledDate,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      entryId: json['entry_id'],
      categoryType: json['category_type'],
      referenceId: json['reference_id'],
      studentId: json['student_id'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
      scheduledStartTime: json['scheduled_start_time'],
      scheduledEndTime: json['scheduled_end_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entry_id': entryId,
      'category_type': categoryType,
      'reference_id': referenceId,
      'student_id': studentId,
      'scheduled_date': scheduledDate.toIso8601String(),
      'scheduled_start_time': scheduledStartTime,
      'scheduled_end_time': scheduledEndTime,
    };
  }
}