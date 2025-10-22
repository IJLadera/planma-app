class SleepLog {
  final int? sleepLogId;
  final String startTime;
  final String endTime;
  final String duration;
  final String dateLogged;

  SleepLog({
    this.sleepLogId,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.dateLogged,
  });

  factory SleepLog.fromJson(Map<String, dynamic> json) {
    return SleepLog(
      sleepLogId: json['sleep_log_id'] as int?,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '', 
      duration: json['duration'] ?? 0, 
      dateLogged: json['date_logged'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sleep_log_id': sleepLogId,
      'start_time': startTime,
      'end_time': endTime,
      'duration': duration,
      'date_logged': dateLogged,
    };
  }
}