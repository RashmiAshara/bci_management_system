import 'package:flutter/foundation.dart';

import '../models/attendance_status.dart';
import '../models/employee_attendance_record.dart';
import '../utils/formatters.dart';

/// Controller for daily employee check-in/check-out attendance.
class EmployeeAttendanceController extends ChangeNotifier {
  final List<EmployeeAttendanceRecord> _employeeAttendance = <EmployeeAttendanceRecord>[];

  List<EmployeeAttendanceRecord> get employeeAttendance =>
      List<EmployeeAttendanceRecord>.unmodifiable(_employeeAttendance);

  List<EmployeeAttendanceRecord> attendanceForEmployee(String employeeId) {
    return _employeeAttendance
        .where((EmployeeAttendanceRecord r) => r.employeeId == employeeId)
        .toList()
      ..sort((EmployeeAttendanceRecord a, EmployeeAttendanceRecord b) => b.date.compareTo(a.date));
  }

  void markEmployeeAttendance({
    required String employeeId,
    required DateTime date,
    required AttendanceStatus status,
    String? checkIn,
    String? checkOut,
  }) {
    _employeeAttendance.removeWhere(
        (EmployeeAttendanceRecord r) => r.employeeId == employeeId && r.date.isSameDate(date));
    _employeeAttendance.add(EmployeeAttendanceRecord(
      id: 'EA-${DateTime.now().microsecondsSinceEpoch}-$employeeId',
      employeeId: employeeId,
      date: date,
      status: status,
      checkIn: checkIn,
      checkOut: checkOut,
    ));
    notifyListeners();
  }
}
