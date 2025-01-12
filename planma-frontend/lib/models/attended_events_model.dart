import 'package:planma_app/models/events_model.dart';

class AttendedEvent {
  final int id;
  final Event? event;
  final String date;
  final bool hasAttended;

  AttendedEvent({
    required this.id,
    required this.event,
    required this.date,
    required this.hasAttended,
  });

  factory AttendedEvent.fromJson(Map<String, dynamic> json) {
    return AttendedEvent(
      id: json['att_events_id'],
      event: json['event_id'] != null
          ? Event.fromJson(json['event_id'])
          : null,
      date: json['date'],
      hasAttended: json['has_attended'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'att_events_id': id,
      'event_id': event?.toJson(),
      'date': date,
      'has_attended': hasAttended,
    };
  }
}
