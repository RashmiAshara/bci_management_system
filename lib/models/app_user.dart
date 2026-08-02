enum UserRole {
  admin,
  registrar,
  hrOfficer,
  financeOfficer,
  payrollApprover,
  lecturer,
  employee,
  student,
}

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Super Administrator';
      case UserRole.registrar:
        return 'Registrar';
      case UserRole.hrOfficer:
        return 'HR Officer';
      case UserRole.financeOfficer:
        return 'Finance Officer';
      case UserRole.payrollApprover:
        return 'Payroll Approver';
      case UserRole.lecturer:
        return 'Lecturer';
      case UserRole.employee:
        return 'Employee';
      case UserRole.student:
        return 'Student';
    }
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.employeeId,
    this.studentId,
  });

  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? employeeId;
  final String? studentId;
}
