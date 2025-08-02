class Goal {
  final int? goalId;
  final String goalName;
  final String? goalDescription;
  final String timeframe;
  final int targetHours;
  final String goalType;
  final int? semester;

  Goal({
    this.goalId,
    required this.goalName,
    required this.goalDescription,
    required this.timeframe,
    required this.targetHours,
    required this.goalType,
    this.semester,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      goalId: json['goal_id'] as int?,
      goalName: json['goal_name'] ?? 'N/A', 
      goalDescription: json['goal_desc'] as String?, 
      timeframe: json['timeframe'] ?? 'Daily', 
      targetHours: json['target_hours'] ?? 0, 
      goalType: json['goal_type'] ?? 'Academic',
      semester: json['semester_id'] != null ? json['semester_id']['semester_id'] as int? : null,
    );
  }

  // Convert Goal instance JSON
  Map<String, dynamic> toJson() {
    return {
      'goal_id': goalId,
      'goal_name': goalName, 
      'goal_desc': goalDescription == null || goalDescription!.trim().isEmpty ? null : goalDescription,
      'timeframe': timeframe, 
      'target_hours': targetHours, 
      'goal_type': goalType,
      'semester_id': semester,
    };
  }
}