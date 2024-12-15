class Event {
  final int? eventId;
  final String eventName;
  final String eventDesc;
  final String location;
  final DateTime scheduledDate;
  final String scheduledStartTime;
  final String scheduledEndTime;
  final String eventType;

  Event({
    this.eventId,
    required this.eventName,
    required this.eventDesc,
    required this.location,
    required this.scheduledDate,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.eventType,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'],
      eventName: json['event_name'],
      eventDesc: json['event_desc'],
      location: json['location'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
      scheduledStartTime: json['scheduled_start_time'] ?? '00:00',
      scheduledEndTime: json['scheduled_end_time'] ?? '00:00',
      eventType: json['event_type'],
    );
    
  }

  // Convert a Event instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'event_name': eventName,
      'event_desc': eventDesc,
      'location': location,
      'scheduled_date': scheduledDate.toIso8601String(),
      'scheduled_start_time': scheduledStartTime,
      'scheduled_end_time': scheduledEndTime,
      'event_type': eventType,
    };
  }
}