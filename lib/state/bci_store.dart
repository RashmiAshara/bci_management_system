import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/attendance_status.dart';
import '../models/course.dart';
import '../models/employee.dart';
import '../models/employee_attendance_record.dart';
import '../models/enrollment.dart';
import '../models/leave_request.dart';
import '../models/module.dart';
import '../models/payroll_period.dart';
import '../models/payslip.dart';
import '../models/salary_component.dart';
import '../models/student.dart';
import '../models/student_attendance_record.dart';

class BciStore extends ChangeNotifier {
  // ---------------------------------------------------------------------
  // Authentication (mock, in-memory, client-side role checks only)
  // ---------------------------------------------------------------------

  final List<AppUser> _users = <AppUser>[
    const AppUser(
      id: 'U-ADMIN',
      name: 'System Administrator',
      email: 'admin@bci.lk',
      password: 'admin123',
      role: UserRole.admin,
    ),
    const AppUser(
      id: 'U-REGISTRAR',
      name: 'Registrar Office',
      email: 'registrar@bci.lk',
      password: 'registrar123',
      role: UserRole.registrar,
    ),
    const AppUser(
      id: 'U-HR',
      name: 'HR Officer',
      email: 'hr@bci.lk',
      password: 'hr123',
      role: UserRole.hrOfficer,
    ),
    const AppUser(
      id: 'U-FINANCE',
      name: 'Finance Officer',
      email: 'finance@bci.lk',
      password: 'finance123',
      role: UserRole.financeOfficer,
    ),
    const AppUser(
      id: 'U-APPROVER',
      name: 'Payroll Approver',
      email: 'approver@bci.lk',
      password: 'approve123',
      role: UserRole.payrollApprover,
    ),
    const AppUser(
      id: 'U-LECTURER',
      name: 'Lecturer',
      email: 'lecturer@bci.lk',
      password: 'lecturer123',
      role: UserRole.lecturer,
    ),
    const AppUser(
      id: 'U-EMPLOYEE',
      name: 'Rashmi Perera',
      email: 'rashmi.emp@bci.lk',
      password: 'employee123',
      role: UserRole.employee,
      employeeId: 'EMP-002',
    ),
    const AppUser(
      id: 'U-STUDENT',
      name: 'Ayesha Perera',
      email: 'ayesha.student@bci.lk',
      password: 'student123',
      role: UserRole.student,
      studentId: 'BCI-2026-001',
    ),
  ];

  List<AppUser> get demoAccounts => List<AppUser>.unmodifiable(_users);

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  bool login(String email, String password) {
    AppUser? match;
    for (final AppUser user in _users) {
      if (user.email.toLowerCase() == email.trim().toLowerCase() &&
          user.password == password) {
        match = user;
        break;
      }
    }
    if (match == null) {
      return false;
    }
    _currentUser = match;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Reference data
  // ---------------------------------------------------------------------

  final List<Module> _modules = <Module>[
    const Module(id: 'MOD-101', code: 'MOD-101', name: 'Introduction to Programming'),
    const Module(id: 'MOD-102', code: 'MOD-102', name: 'Database Systems'),
    const Module(id: 'MOD-103', code: 'MOD-103', name: 'Software Engineering Practices'),
  ];

  List<Module> get modules => List<Module>.unmodifiable(_modules);

  Module? moduleById(String id) {
    for (final Module module in _modules) {
      if (module.id == id) return module;
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Students
  // ---------------------------------------------------------------------

  final List<Student> _students = <Student>[
    const Student(
      id: 'BCI-2026-001',
      name: 'Ayesha Perera',
      email: 'ayesha@students.bci.lk',
      program: 'BSc Software Engineering',
      intake: 'February 2026',
      status: 'Active',
    ),
    const Student(
      id: 'BCI-2026-002',
      name: 'Nimal Fernando',
      email: 'nimal@students.bci.lk',
      program: 'BSc Information Technology',
      intake: 'February 2026',
      status: 'Active',
    ),
    const Student(
      id: 'BCI-2025-118',
      name: 'Tharushi Silva',
      email: 'tharushi@students.bci.lk',
      program: 'BSc Computer Science',
      intake: 'September 2025',
      status: 'Active',
    ),
  ];

  List<Student> get students => List<Student>.unmodifiable(_students);

  Student? studentById(String id) {
    for (final Student student in _students) {
      if (student.id == id) return student;
    }
    return null;
  }

  int get activeStudentCount =>
      _students.where((Student student) => student.status == 'Active').length;

  void addStudent(Student student) {
    _students.add(student);
    notifyListeners();
  }

  void updateStudent(Student student) {
    final int index = _students.indexWhere((Student s) => s.id == student.id);
    if (index == -1) return;
    _students[index] = student;
    notifyListeners();
  }

  void removeStudent(String studentId) {
    _students.removeWhere((Student student) => student.id == studentId);
    _enrollments.removeWhere((Enrollment e) => e.studentId == studentId);
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Courses
  // ---------------------------------------------------------------------

  final List<Course> _courses = <Course>[
    const Course(
      id: 'CRS-1001',
      code: 'CS101',
      name: 'Introduction to Programming',
      credits: 3,
      description: 'Fundamentals of programming using a modern language.',
    ),
    const Course(
      id: 'CRS-1002',
      code: 'CS205',
      name: 'Database Systems',
      credits: 4,
      description: 'Relational database design, SQL and normalisation.',
    ),
    const Course(
      id: 'CRS-1003',
      code: 'SE210',
      name: 'Software Engineering Practices',
      credits: 3,
      description: 'Software development lifecycle, testing and teamwork.',
    ),
  ];

  List<Course> get courses => List<Course>.unmodifiable(_courses);

  Course? courseById(String id) {
    for (final Course course in _courses) {
      if (course.id == id) return course;
    }
    return null;
  }

  void addCourse(Course course) {
    _courses.add(course);
    notifyListeners();
  }

  void updateCourse(Course course) {
    final int index = _courses.indexWhere((Course c) => c.id == course.id);
    if (index == -1) return;
    _courses[index] = course;
    notifyListeners();
  }

  void removeCourse(String courseId) {
    _courses.removeWhere((Course course) => course.id == courseId);
    _enrollments.removeWhere((Enrollment e) => e.courseId == courseId);
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Enrollment
  // ---------------------------------------------------------------------

  final List<Enrollment> _enrollments = <Enrollment>[
    Enrollment(
      id: 'ENR-0001',
      studentId: 'BCI-2026-001',
      courseId: 'CRS-1001',
      enrolledOn: DateTime(2026, 2, 3),
    ),
    Enrollment(
      id: 'ENR-0002',
      studentId: 'BCI-2026-001',
      courseId: 'CRS-1002',
      enrolledOn: DateTime(2026, 2, 3),
    ),
    Enrollment(
      id: 'ENR-0003',
      studentId: 'BCI-2026-002',
      courseId: 'CRS-1001',
      enrolledOn: DateTime(2026, 2, 4),
    ),
  ];

  List<Enrollment> get enrollments => List<Enrollment>.unmodifiable(_enrollments);

  List<Course> coursesForStudent(String studentId) {
    final List<String> courseIds = _enrollments
        .where((Enrollment e) => e.studentId == studentId)
        .map((Enrollment e) => e.courseId)
        .toList();
    return courseIds
        .map((String id) => courseById(id))
        .whereType<Course>()
        .toList();
  }

  List<Student> studentsForCourse(String courseId) {
    final List<String> studentIds = _enrollments
        .where((Enrollment e) => e.courseId == courseId)
        .map((Enrollment e) => e.studentId)
        .toList();
    return studentIds
        .map((String id) => studentById(id))
        .whereType<Student>()
        .toList();
  }

  bool isEnrolled(String studentId, String courseId) {
    return _enrollments.any(
      (Enrollment e) => e.studentId == studentId && e.courseId == courseId,
    );
  }

  void enrollStudent(String studentId, String courseId) {
    if (isEnrolled(studentId, courseId)) return;
    _enrollments.add(Enrollment(
      id: 'ENR-${DateTime.now().microsecondsSinceEpoch}',
      studentId: studentId,
      courseId: courseId,
      enrolledOn: DateTime.now(),
    ));
    notifyListeners();
  }

  void unenrollStudent(String studentId, String courseId) {
    _enrollments.removeWhere(
      (Enrollment e) => e.studentId == studentId && e.courseId == courseId,
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Employees
  // ---------------------------------------------------------------------

  final List<Employee> _employees = <Employee>[
    const Employee(
      id: 'EMP-001',
      name: 'Dr. Amal Jayasinghe',
      department: 'School of Computing',
      designation: 'Senior Lecturer',
      basicSalary: 185000,
      overtime: 12000,
      tax: 17500,
      allowances: <SalaryComponent>[
        SalaryComponent(name: 'Cost of Living Allowance', amount: 20000),
        SalaryComponent(name: 'Transport Allowance', amount: 15000),
      ],
      deductions: <SalaryComponent>[
        SalaryComponent(name: 'Loan Instalment', amount: 8500),
      ],
    ),
    const Employee(
      id: 'EMP-002',
      name: 'Rashmi Perera',
      department: 'Finance',
      designation: 'Finance Officer',
      basicSalary: 125000,
      overtime: 6500,
      tax: 9500,
      allowances: <SalaryComponent>[
        SalaryComponent(name: 'Cost of Living Allowance', amount: 14000),
        SalaryComponent(name: 'Telephone Allowance', amount: 8000),
      ],
      deductions: <SalaryComponent>[
        SalaryComponent(name: 'Staff Welfare Fund', amount: 5000),
      ],
    ),
    const Employee(
      id: 'EMP-003',
      name: 'Kamal Fernando',
      department: 'Administration',
      designation: 'Management Assistant',
      basicSalary: 95000,
      overtime: 8000,
      tax: 4200,
      allowances: <SalaryComponent>[
        SalaryComponent(name: 'Transport Allowance', amount: 10000),
        SalaryComponent(name: 'Meal Allowance', amount: 8000),
      ],
      deductions: <SalaryComponent>[
        SalaryComponent(name: 'Salary Advance', amount: 3500),
      ],
    ),
  ];

  List<Employee> get employees => List<Employee>.unmodifiable(_employees);

  List<Employee> get activeEmployees =>
      _employees.where((Employee employee) => employee.active).toList();

  Employee? employeeById(String id) {
    for (final Employee employee in _employees) {
      if (employee.id == id) return employee;
    }
    return null;
  }

  double get monthlyPayrollTotal => _employees.fold<double>(
        0,
        (double sum, Employee employee) => sum + employee.netSalary,
      );

  void addEmployee(Employee employee) {
    _employees.add(employee);
    notifyListeners();
  }

  void updateEmployee(Employee employee) {
    final int index = _employees.indexWhere((Employee e) => e.id == employee.id);
    if (index == -1) return;
    _employees[index] = employee;
    notifyListeners();
  }

  void removeEmployee(String employeeId) {
    _employees.removeWhere((Employee employee) => employee.id == employeeId);
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Student attendance
  // ---------------------------------------------------------------------

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
        r.studentId == studentId && r.moduleId == moduleId && _isSameDay(r.date, date));
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

  // ---------------------------------------------------------------------
  // Employee attendance
  // ---------------------------------------------------------------------

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
        (EmployeeAttendanceRecord r) => r.employeeId == employeeId && _isSameDay(r.date, date));
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

  // ---------------------------------------------------------------------
  // Leave
  // ---------------------------------------------------------------------

  static const Map<LeaveType, int> leaveEntitlement = <LeaveType, int>{
    LeaveType.annual: 14,
    LeaveType.casual: 7,
    LeaveType.medical: 7,
    LeaveType.noPay: 0,
  };

  final List<LeaveRequest> _leaveRequests = <LeaveRequest>[];

  List<LeaveRequest> get leaveRequests => List<LeaveRequest>.unmodifiable(_leaveRequests);

  List<LeaveRequest> leaveRequestsForEmployee(String employeeId) {
    return _leaveRequests.where((LeaveRequest r) => r.employeeId == employeeId).toList()
      ..sort((LeaveRequest a, LeaveRequest b) => b.appliedOn.compareTo(a.appliedOn));
  }

  int get pendingLeaveCount =>
      _leaveRequests.where((LeaveRequest r) => r.status == LeaveStatus.pending).length;

  int leaveBalance(String employeeId, LeaveType type) {
    final int entitlement = leaveEntitlement[type] ?? 0;
    final int used = _leaveRequests
        .where((LeaveRequest r) =>
            r.employeeId == employeeId && r.leaveType == type && r.status == LeaveStatus.approved)
        .fold<int>(0, (int sum, LeaveRequest r) => sum + r.durationInDays);
    return entitlement - used;
  }

  void applyLeave({
    required String employeeId,
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) {
    _leaveRequests.add(LeaveRequest(
      id: 'LR-${DateTime.now().microsecondsSinceEpoch}',
      employeeId: employeeId,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      appliedOn: DateTime.now(),
    ));
    notifyListeners();
  }

  void _setLeaveStatus(String id, LeaveStatus status) {
    final int index = _leaveRequests.indexWhere((LeaveRequest r) => r.id == id);
    if (index == -1) return;
    _leaveRequests[index] = _leaveRequests[index].copyWith(status: status);
    notifyListeners();
  }

  void approveLeave(String id) => _setLeaveStatus(id, LeaveStatus.approved);

  void rejectLeave(String id) => _setLeaveStatus(id, LeaveStatus.rejected);

  // ---------------------------------------------------------------------
  // Payroll
  // ---------------------------------------------------------------------

  final List<PayrollPeriod> _payrollPeriods = <PayrollPeriod>[];
  final List<Payslip> _payslips = <Payslip>[];

  List<PayrollPeriod> get payrollPeriods {
    final List<PayrollPeriod> sorted = List<PayrollPeriod>.of(_payrollPeriods);
    sorted.sort((PayrollPeriod a, PayrollPeriod b) => b.startDate.compareTo(a.startDate));
    return List<PayrollPeriod>.unmodifiable(sorted);
  }

  int get pendingPayrollApprovalCount => _payrollPeriods
      .where((PayrollPeriod p) => p.status == PayrollPeriodStatus.generated)
      .length;

  void createPayrollPeriod({
    required String label,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    _payrollPeriods.add(PayrollPeriod(
      id: 'PP-${DateTime.now().microsecondsSinceEpoch}',
      label: label,
      startDate: startDate,
      endDate: endDate,
    ));
    notifyListeners();
  }

  void generatePayroll(String periodId) {
    final int periodIndex = _payrollPeriods.indexWhere((PayrollPeriod p) => p.id == periodId);
    if (periodIndex == -1) return;
    final PayrollPeriod period = _payrollPeriods[periodIndex];

    _payslips.removeWhere((Payslip p) => p.periodId == periodId);

    for (final Employee employee in activeEmployees) {
      final int noPayDays = _leaveRequests
          .where((LeaveRequest r) =>
              r.employeeId == employee.id &&
              r.leaveType == LeaveType.noPay &&
              r.status == LeaveStatus.approved &&
              r.overlaps(period.startDate, period.endDate))
          .fold<int>(0, (int sum, LeaveRequest r) => sum + r.durationInDays);

      final double dailyRate = employee.basicSalary / 30;
      final double noPayDeduction = dailyRate * noPayDays;

      final List<SalaryComponent> earnings = <SalaryComponent>[
        ...employee.allowances,
        if (employee.overtime > 0) SalaryComponent(name: 'Overtime', amount: employee.overtime),
      ];

      final List<SalaryComponent> deductions = <SalaryComponent>[
        ...employee.deductions,
        if (employee.tax > 0) SalaryComponent(name: 'Tax', amount: employee.tax),
        if (noPayDeduction > 0)
          SalaryComponent(name: 'No-Pay Leave ($noPayDays day(s))', amount: noPayDeduction),
      ];

      _payslips.add(Payslip(
        id: 'PS-$periodId-${employee.id}',
        periodId: periodId,
        employeeId: employee.id,
        basicSalary: employee.basicSalary,
        earnings: earnings,
        deductions: deductions,
      ));
    }

    _payrollPeriods[periodIndex] = period.copyWith(status: PayrollPeriodStatus.generated);
    notifyListeners();
  }

  void approvePayrollPeriod(String periodId) {
    final int periodIndex = _payrollPeriods.indexWhere((PayrollPeriod p) => p.id == periodId);
    if (periodIndex == -1) return;
    _payrollPeriods[periodIndex] =
        _payrollPeriods[periodIndex].copyWith(status: PayrollPeriodStatus.approved);

    for (int i = 0; i < _payslips.length; i++) {
      if (_payslips[i].periodId == periodId) {
        _payslips[i] = _payslips[i].copyWith(status: PayslipStatus.approved);
      }
    }
    notifyListeners();
  }

  List<Payslip> payslipsForPeriod(String periodId) =>
      _payslips.where((Payslip p) => p.periodId == periodId).toList();

  List<Payslip> payslipsForEmployee(String employeeId) =>
      _payslips.where((Payslip p) => p.employeeId == employeeId).toList();

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
