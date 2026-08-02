import 'attendance_status.dart';

class StudentAttendanceRecord {
  const StudentAttendanceRecord({
    required this.id,
    required this.studentId,
    required this.moduleId,
    required this.date,
    required this.status,
    this.remarks = '',
  });

  final String id;
  final String studentId;
  final String moduleId;
  final DateTime date;
  final AttendanceStatus status;
  final String remarks;
}
