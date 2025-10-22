class ClassSchedule {
  final int? classschedId;
  final int? subjectId;
  final String subjectCode;
  final String subjectTitle;
  final int semesterId;
  final String dayOfWeek;
  final String scheduledStartTime;
  final String scheduledEndTime;
  final String room;

  ClassSchedule({
    this.classschedId,
    this.subjectId,
    required this.subjectCode,
    required this.subjectTitle,
    required this.semesterId,
    required this.dayOfWeek,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.room,
  });

  // Factory method to create an instance from JSON
  factory ClassSchedule.fromJson(Map<String, dynamic> json) {
    return ClassSchedule(
      classschedId: json['classsched_id'] as int?,
      subjectId: json['subject']['subject_id'] as int?,
      subjectCode: json['subject']['subject_code'] ?? 'N/A',
      subjectTitle: json['subject']['subject_title'] ?? 'N/A',
      semesterId: json['subject']['semester_id'] != null
          ? json['subject']['semester_id']['semester_id'] ?? 0
          : 0,
      dayOfWeek: json['day_of_week'] ?? 'Unknown',
      scheduledStartTime: json['scheduled_start_time'] ?? '00:00',
      scheduledEndTime: json['scheduled_end_time'] ?? '00:00',
      room: json['room'] ?? 'No Room',
    );
  }

  // Convert a ClassSchedule instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'classsched_id': classschedId,
      'subject_id': subjectId,
      'subject_code': subjectCode,
      'subject_title': subjectTitle,
      'semester_id': semesterId,
      'day_of_week': dayOfWeek,
      'scheduled_start_time': scheduledStartTime,
      'scheduled_end_time': scheduledEndTime,
      'room': room,
    };
  }
}
