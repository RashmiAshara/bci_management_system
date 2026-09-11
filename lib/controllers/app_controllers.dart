import 'auth_controller.dart';
import 'course_controller.dart';
import 'employee_attendance_controller.dart';
import 'employee_controller.dart';
import 'enrollment_controller.dart';
import 'leave_controller.dart';
import 'payroll_controller.dart';
import 'student_attendance_controller.dart';
import 'student_controller.dart';

/// Composition root: constructs every feature controller and wires the
/// few cross-controller collaborators (e.g. payroll generation needs the
/// employee roster and leave records). Views hold references to just the
/// individual controllers they need, obtained from this facade — they
/// never reach into another screen's controller.
class AppControllers {
  AppControllers()
      : auth = AuthController(),
        enrollment = EnrollmentController(),
        employees = EmployeeController(),
        studentAttendance = StudentAttendanceController(),
        employeeAttendance = EmployeeAttendanceController(),
        leave = LeaveController() {
    students = StudentController(enrollment);
    courses = CourseController(enrollment);
    payroll = PayrollController(employees, leave);
  }

  final AuthController auth;
  late final StudentController students;
  late final CourseController courses;
  final EnrollmentController enrollment;
  final EmployeeController employees;
  final StudentAttendanceController studentAttendance;
  final EmployeeAttendanceController employeeAttendance;
  final LeaveController leave;
  late final PayrollController payroll;

  void dispose() {
    auth.dispose();
    students.dispose();
    courses.dispose();
    enrollment.dispose();
    employees.dispose();
    studentAttendance.dispose();
    employeeAttendance.dispose();
    leave.dispose();
    payroll.dispose();
  }
}
