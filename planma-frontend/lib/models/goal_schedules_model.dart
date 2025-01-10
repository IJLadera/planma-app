import 'package:planma_app/models/goals_model.dart';

class GoalSchedule {
  final int? goalScheduleId;
  final Goal? goal;
  final String scheduledDate;
  final String scheduledStartTime;
  final String scheduledEndTime;

  GoalSchedule({
    this.goalScheduleId,
    required this.goal,
    required this.scheduledDate,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
  });

  factory GoalSchedule.fromJson(Map<String, dynamic> json) {
    return GoalSchedule(
      goalScheduleId: json['goalschedule_id'] as int?,
      goal: json['goal_id'] != null
          ? Goal.fromJson(json['goal_id'])
          : null,
      scheduledDate: json['scheduled_date'] ?? '',
      scheduledStartTime: json['scheduled_start_time'] ?? '',
      scheduledEndTime: json['scheduled_end_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goalschedule_id': goalScheduleId,
      'goal_id': goal?.toJson(),
      'scheduled_date': scheduledDate,
      'scheduled_start_time': scheduledStartTime,
      'scheduled_end_time': scheduledEndTime,
    };
  }
}