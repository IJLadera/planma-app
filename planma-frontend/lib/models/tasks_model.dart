import 'package:planma_app/models/subjects_model.dart';

class Task {
  final int? taskId;
  final String taskName;
  final String? taskDescription;
  final DateTime scheduledDate;
  final String scheduledStartTime;
  final String scheduledEndTime;
  final DateTime deadline;
  String? status;
  final Subject? subject;

  Task({
    this.taskId,
    required this.taskName,
    required this.taskDescription,
    required this.scheduledDate,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.deadline,
    this.status,
    this.subject,
  });

  // Factory method to create an instance from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
  return Task(
    taskId: json['task_id'] as int?, // Optional
    taskName: json['task_name'] ?? 'N/A', // Default if null
    taskDescription: json['task_desc'] as String?, // Default if null
    scheduledDate: DateTime.parse(json['scheduled_date']),
    scheduledStartTime: json['scheduled_start_time'] ?? '00:00',
    scheduledEndTime: json['scheduled_end_time'] ?? '00:00', // Default time
    deadline: DateTime.parse(json['deadline']),
    status: json['status'] ?? 'Pending',
    subject: json['subject_id'] != null ? Subject.fromJson(json['subject_id']) : null,
  );
}


  // Convert a Task instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'task_name': taskName,
      'task_desc': taskDescription == null || taskDescription!.trim().isEmpty ? null : taskDescription,
      'scheduled_date': scheduledDate.toIso8601String(),
      'scheduled_start_time': scheduledStartTime,
      'scheduled_end_time': scheduledEndTime,
      'deadline': deadline.toIso8601String(),
      'status': status,
      'subject_id': subject?.subjectId,
    };
  }
}