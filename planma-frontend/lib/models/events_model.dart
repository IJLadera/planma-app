class Event {
  final String eventName;
  final String eventDesc;
  final String location;
  final String date;
  final String time;
  final String eventType;

  Event({
    required this.eventName,
    required this.eventDesc,
    required this.location,
    required this.date,
    required this.time,
    required this.eventType,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventName: json['event_name'],
      eventDesc: json['event_desc'],
      location: json['location'],
      date: json['scheduled_date'],
      time: "${json['scheduled_start_time']} - ${json['scheduled_end_time']}",
      eventType: json['event_type'],
    );
  }
}