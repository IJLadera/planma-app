import 'package:planma_app/models/activity_model.dart';

class ActivityTimeLog {
  final int? activityLogId;
  final Activity? activityId;
  final String startTime;
  final String endTime;
  final String duration;
  final String dateLogged;

  ActivityTimeLog({
    this.activityLogId,
    required this.activityId,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.dateLogged,
  });

  factory ActivityTimeLog.fromJson(Map<String, dynamic> json) {
    return ActivityTimeLog(
      activityLogId: json['activity_log_id'] as int?,
      activityId: json['activity_id'] != null ? Activity.fromJson(json['activity_id']) : null,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '', 
      duration: json['duration'] ?? 0, 
      dateLogged: json['date_logged'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_log_id': activityLogId,
      'activity_id': activityId,
      'start_time': startTime,
      'end_time': endTime,
      'duration': duration,
      'date_logged': dateLogged,
    };
  }
}