import 'package:planma_app/models/goal_schedules_model.dart';
import 'package:planma_app/models/goals_model.dart';

class GoalProgress {
  final int? goalProgressId;
  final Goal? goalId;
  final GoalSchedule? goalScheduleId;
  final String startTime;
  final String endTime;
  final String duration;
  final String dateLogged;

  GoalProgress({
    this.goalProgressId,
    required this.goalId,
    required this.goalScheduleId,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.dateLogged,
  });

  factory GoalProgress.fromJson(Map<String, dynamic> json) {
    return GoalProgress(
      goalProgressId: json['goalprogress_id'] as int?,
      goalId: json['goal_id'] != null ? Goal.fromJson(json['goal_id']) : null,
      goalScheduleId: json['goalschedule_id'] != null
          ? GoalSchedule.fromJson(json['goalschedule_id'])
          : null,
      startTime: json['session_start_time'] ?? '',
      endTime: json['session_end_time'] ?? '',
      duration: json['session_duration'] ?? '',
      dateLogged: json['session_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goalprogress_id': goalProgressId,
      'goal_id': goalId,
      'goalschedule_id': goalScheduleId,
      'session_start_time': startTime,
      'session_end_time': endTime,
      'session_duration': duration,
      'session_date': dateLogged,
    };
  }
}
