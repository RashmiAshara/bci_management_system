import 'attendance_status.dart';

class EmployeeAttendanceRecord {
  const EmployeeAttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
  });

  final String id;
  final String employeeId;
  final DateTime date;
  final AttendanceStatus status;
  final String? checkIn;
  final String? checkOut;
}
