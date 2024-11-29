class Task {
  final int? taskId;
  final String taskName;
  final String taskDescription;
  final DateTime scheduledDate;
  final String scheduledStartTime;
  final String scheduledEndTime;
  final DateTime deadline;
  final String status;
  final String subjectCode;

  Task({
    this.taskId,
    required this.taskName,
    required this.taskDescription,
    required this.scheduledDate,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.deadline,
    required this.status,
    required this.subjectCode,
  });

  // Factory method to create an instance from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
  return Task(
    taskId: json['task_id'] as int?, // Optional
    taskName: json['task_name'] ?? 'N/A', // Default if null
    taskDescription: json['task_desc'] ?? 'N/A', // Default if null
    scheduledDate: json['scheduled_date'] ?? 0, // Default to 0 if null
    scheduledStartTime: json['scheduled_start_time'] ?? '00:00',
    scheduledEndTime: json['scheduled_end_time'] ?? '00:00', // Default time
    deadline: json['deadline'] ?? 0,
    status: json['status'] ?? 'Pending',
    subjectCode: json['subject_code'],
  );
}


  // Convert a Task instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'task_name': taskName,
      'task_desc': taskDescription,
      'scheduled_date': scheduledDate,
      'scheduled_start_time': scheduledStartTime,
      'scheduled_end_time': scheduledEndTime,
      'deadline': deadline,
      'status': status,
      'subject_code': subjectCode,
    };
  }
}