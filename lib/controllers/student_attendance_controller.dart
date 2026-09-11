import 'package:flutter/foundation.dart';

import '../models/attendance_status.dart';
import '../models/module.dart';
import '../models/student_attendance_record.dart';
import '../utils/collection_utils.dart';
import '../utils/formatters.dart';

/// Controller for the module reference data and per-module student
/// attendance marking/reporting.
class StudentAttendanceController extends ChangeNotifier {
  final List<Module> _modules = <Module>[
    const Module(id: 'MOD-101', code: 'MOD-101', name: 'Introduction to Programming'),
    const Module(id: 'MOD-102', code: 'MOD-102', name: 'Database Systems'),
    const Module(id: 'MOD-103', code: 'MOD-103', name: 'Software Engineering Practices'),
  ];

  List<Module> get modules => List<Module>.unmodifiable(_modules);

  Module? moduleById(String id) => findById(_modules, id, (Module m) => m.id);

  final List<StudentAttendanceRecord> _studentAttendance = <StudentAttendanceRecord>[];

  List<StudentAttendanceRecord> get studentAttendance =>
      List<StudentAttendanceRecord>.unmodifiable(_studentAttendance);

  void markStudentAttendance({
    required String studentId,
    required String moduleId,
    required DateTime date,
    required AttendanceStatus status,
    String remarks = '',
  }) {
    _studentAttendance.removeWhere((StudentAttendanceRecord r) =>
        r.studentId == studentId && r.moduleId == moduleId && r.date.isSameDate(date));
    _studentAttendance.add(StudentAttendanceRecord(
      id: 'SA-${DateTime.now().microsecondsSinceEpoch}-$studentId',
      studentId: studentId,
      moduleId: moduleId,
      date: date,
      status: status,
      remarks: remarks,
    ));
    notifyListeners();
  }

  double attendancePercentage(String studentId) {
    final List<StudentAttendanceRecord> records =
        _studentAttendance.where((StudentAttendanceRecord r) => r.studentId == studentId).toList();
    if (records.isEmpty) return 0;
    final int present = records
        .where((StudentAttendanceRecord r) =>
            r.status == AttendanceStatus.present || r.status == AttendanceStatus.late)
        .length;
    return present / records.length * 100;
  }
}
