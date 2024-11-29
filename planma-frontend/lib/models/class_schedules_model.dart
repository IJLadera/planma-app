class ClassSchedule {
  final int? classschedId;
  final String subjectCode;
  final String subjectTitle;
  final int semesterId;
  final String dayOfWeek;
  final String scheduledStartTime;
  final String scheduledEndTime;
  final String room;

  ClassSchedule({
    this.classschedId,
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
    classschedId: json['classsched_id'] as int?, // Optional
    subjectCode: json['subject_code'] ?? 'N/A', // Default if null
    subjectTitle: json['subject_title'] ?? 'N/A', // Default if null
    semesterId: json['semester_id'] ?? 0, // Default to 0 if null
    dayOfWeek: json['day_of_week'] ?? 'Unknown',
    scheduledStartTime: json['scheduled_start_time'] ?? '00:00', // Default time
    scheduledEndTime: json['scheduled_end_time'] ?? '00:00',
    room: json['room'] ?? 'No Room',
  );
}


  // Convert a ClassSchedule instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'classsched_id': classschedId,
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