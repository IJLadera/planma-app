class Semester {
  final int id;
  final String semester;
  final String yearLevel;
  final int acadYearStart;
  final int acadYearEnd;
  final DateTime startDate;
  final DateTime endDate;

  Semester({
    required this.id,
    required this.semester,
    required this.yearLevel,
    required this.acadYearStart,
    required this.acadYearEnd,
    required this.startDate,
    required this.endDate,
  });

  // Factory constructor to create a Semester object from JSON
  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'],
      semester: json['semester'],
      yearLevel: json['year_level'],
      acadYearStart: json['acad_year_start'],
      acadYearEnd: json['acad_year_end'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }
}