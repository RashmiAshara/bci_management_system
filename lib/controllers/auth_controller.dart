import 'package:flutter/foundation.dart';

import '../models/app_user.dart';

/// Controller for the (mock, in-memory) authentication flow: holds the
/// demo user directory, the currently signed-in user, and role-based
/// sign-in/sign-out behaviour. Views read [currentUser] and call [login]/
/// [logout]; they never touch user records directly.
class AuthController extends ChangeNotifier {
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
}
