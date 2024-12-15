class Activity {
  final int? activityId;
  final String activityName;
  final String activityDescription;
  final DateTime scheduledDate;
  final String scheduledStartTime;
  final String scheduledEndTime;
  final String? status;

  Activity({
    this.activityId,
    required this.activityName,
    required this.activityDescription,
    required this.scheduledDate,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    this.status,
  });

  // Factory method to create an instance from JSON
  factory Activity.fromJson(Map<String, dynamic> json) {
  return Activity(
    activityId: json['activity_id'] as int?, // Optional
    activityName: json['activity_name'] ?? 'N/A', // Default if null
    activityDescription: json['activity_desc'] ?? 'N/A', // Default if null
    scheduledDate: DateTime.parse(json['scheduled_date']),
    scheduledStartTime: json['scheduled_start_time'] ?? '00:00',
    scheduledEndTime: json['scheduled_end_time'] ?? '00:00', // Default time
    status: json['status'] ?? 'Pending',
  );
}


  // Convert a activity instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'activity_id': activityId,
      'activity_name': activityName,
      'activity_desc': activityDescription,
      'scheduled_date': scheduledDate.toIso8601String(),
      'scheduled_start_time': scheduledStartTime,
      'scheduled_end_time': scheduledEndTime,
      'status': status,
    };
  }
}