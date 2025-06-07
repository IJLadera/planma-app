import 'package:planma_app/models/class_schedules_model.dart';

class AttendedClass {
  final int id;
  final ClassSchedule? classSchedule;
  final String attendanceDate;
  final String status;

  AttendedClass({
    required this.id,
    required this.classSchedule,
    required this.attendanceDate,
    required this.status,
  });

  AttendedClass copyWith({
    int? id,
    ClassSchedule? classSchedule,
    String? attendanceDate,
    String? status,
  }) {
    return AttendedClass(
      id: id ?? this.id, 
      classSchedule: classSchedule ?? this.classSchedule, 
      attendanceDate: attendanceDate ?? this.attendanceDate, 
      status: status ?? this.status,
    );
  }

  factory AttendedClass.fromJson(Map<String, dynamic> json) {
    return AttendedClass(
      id: json['att_class_id'], 
      classSchedule: json['classsched_id'] != null
          ? ClassSchedule.fromJson(json['classsched_id'])
          : null, 
      attendanceDate: json['attendance_date'], 
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'att_class_id': id,
      'classsched_id': classSchedule?.toJson(),
      'attendance_date': attendanceDate,
      'status': status,
    };
  }
}