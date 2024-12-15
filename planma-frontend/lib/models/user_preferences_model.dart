class UserPreferences {
  final int? prefId;
  final String usualSleepTime;
  final String usualWakeTime;
  final String reminderOffsetTime;

  UserPreferences ({
    this.prefId,
    required this.usualSleepTime,
    required this.usualWakeTime,
    required this.reminderOffsetTime,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
  return UserPreferences(
    prefId: json['pref_id'] as int?,
    usualSleepTime: json['usual_sleep_time'] ?? '00:00',
    usualWakeTime: json['usual_wake_time'] ?? '00:00',
    reminderOffsetTime: json['reminder_offset_time'] ?? '00:00',
  );
}

  // Convert a Task instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'pref_id': prefId,
      'usual_sleep_time': usualSleepTime,
      'usual_wake_time': usualWakeTime,
      'reminder_offset_time': reminderOffsetTime,
    };
  }
}