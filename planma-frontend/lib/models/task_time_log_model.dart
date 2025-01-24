import 'package:planma_app/models/tasks_model.dart';

class TaskTimeLog {
  final int? taskLogId;
  final Task? taskId;
  final String startTime;
  final String endTime;
  final String duration;
  final String dateLogged;

  TaskTimeLog({
    this.taskLogId,
    required this.taskId,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.dateLogged,
  });

  factory TaskTimeLog.fromJson(Map<String, dynamic> json) {
    return TaskTimeLog(
      taskLogId: json['task_log_id'] as int?,
      taskId: json['task_id'] != null ? Task.fromJson(json['task_id']) : null,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '', 
      duration: json['duration'] ?? 0, 
      dateLogged: json['date_logged'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_log_id': taskLogId,
      'task_id': taskId,
      'start_time': startTime,
      'end_time': endTime,
      'duration': duration,
      'date_logged': dateLogged,
    };
  }
}