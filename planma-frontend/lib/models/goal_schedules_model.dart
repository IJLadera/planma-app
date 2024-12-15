class GoalSchedule {
  final int? goalScheduleId;
  final int goalId;
  final DateTime scheduledDate;
  final String scheduledStartTime;
  final String scheduledEndTime;

  GoalSchedule ({
    this.goalScheduleId,
    required this.goalId,
    required this.scheduledDate,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
  });

  factory GoalSchedule.fromJson(Map<String, dynamic> json) {
  return GoalSchedule(
    goalScheduleId: json['goalschedule_id'] as int?, // Optional
    goalId: json['goal_id'] ?? 0, // Default if null
    scheduledDate: DateTime.parse(json['scheduled_date']),
    scheduledStartTime: json['scheduled_start_time'] ?? '00:00',
    scheduledEndTime: json['scheduled_end_time'] ?? '00:00', // Default time
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goalschedule_id': goalScheduleId,
      'goal_id': goalId,
      'scheduled_date': scheduledDate.toIso8601String(),
      'scheduled_start_time': scheduledStartTime,
      'scheduled_end_time': scheduledEndTime,
    };
  }
}