import 'package:flutter/material.dart';

import '../controllers/app_controllers.dart';
import '../models/app_user.dart';
import 'courses_screen.dart';
import 'dashboard_screen.dart';
import 'employee_attendance_screen.dart';
import 'employees_screen.dart';
import 'leave_screen.dart';
import 'payroll_screen.dart';
import 'profile_screen.dart';
import 'student_attendance_screen.dart';
import 'students_screen.dart';

enum _NavKey {
  dashboard,
  students,
  courses,
  studentAttendance,
  employees,
  employeeAttendance,
  leave,
  payroll,
}

class _NavSpec {
  const _NavSpec({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.builder,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget Function(AppControllers controllers) builder;
}

final Map<_NavKey, _NavSpec> _navSpecs = <_NavKey, _NavSpec>{
  _NavKey.dashboard: _NavSpec(
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: 'Dashboard',
    builder: (AppControllers controllers) => DashboardScreen(controllers: controllers),
  ),
  _NavKey.students: _NavSpec(
    icon: Icons.school_outlined,
    selectedIcon: Icons.school,
    label: 'Students',
    builder: (AppControllers controllers) => StudentsScreen(
      students: controllers.students,
      courses: controllers.courses,
      enrollment: controllers.enrollment,
    ),
  ),
  _NavKey.courses: _NavSpec(
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book,
    label: 'Courses',
    builder: (AppControllers controllers) => CoursesScreen(
      courses: controllers.courses,
      enrollment: controllers.enrollment,
    ),
  ),
  _NavKey.studentAttendance: _NavSpec(
    icon: Icons.fact_check_outlined,
    selectedIcon: Icons.fact_check,
    label: 'Student Attendance',
    builder: (AppControllers controllers) => StudentAttendanceScreen(
      auth: controllers.auth,
      attendance: controllers.studentAttendance,
      students: controllers.students,
    ),
  ),
  _NavKey.employees: _NavSpec(
    icon: Icons.badge_outlined,
    selectedIcon: Icons.badge,
    label: 'Employees',
    builder: (AppControllers controllers) => EmployeesScreen(employees: controllers.employees),
  ),
  _NavKey.employeeAttendance: _NavSpec(
    icon: Icons.punch_clock_outlined,
    selectedIcon: Icons.punch_clock,
    label: 'Staff Attendance',
    builder: (AppControllers controllers) => EmployeeAttendanceScreen(
      auth: controllers.auth,
      attendance: controllers.employeeAttendance,
      employees: controllers.employees,
    ),
  ),
  _NavKey.leave: _NavSpec(
    icon: Icons.event_busy_outlined,
    selectedIcon: Icons.event_busy,
    label: 'Leave',
    builder: (AppControllers controllers) => LeaveScreen(
      auth: controllers.auth,
      leave: controllers.leave,
      employees: controllers.employees,
    ),
  ),
  _NavKey.payroll: _NavSpec(
    icon: Icons.payments_outlined,
    selectedIcon: Icons.payments,
    label: 'Payroll',
    builder: (AppControllers controllers) => PayrollScreen(
      auth: controllers.auth,
      payroll: controllers.payroll,
      employees: controllers.employees,
    ),
  ),
};

List<_NavKey> _keysForRole(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return const <_NavKey>[
        _NavKey.dashboard,
        _NavKey.students,
        _NavKey.courses,
        _NavKey.studentAttendance,
        _NavKey.employees,
        _NavKey.employeeAttendance,
        _NavKey.leave,
        _NavKey.payroll,
      ];
    case UserRole.registrar:
      return const <_NavKey>[
        _NavKey.dashboard,
        _NavKey.students,
        _NavKey.courses,
        _NavKey.studentAttendance,
      ];
    case UserRole.lecturer:
      return const <_NavKey>[_NavKey.dashboard, _NavKey.studentAttendance];
    case UserRole.hrOfficer:
      return const <_NavKey>[
        _NavKey.dashboard,
        _NavKey.employees,
        _NavKey.employeeAttendance,
        _NavKey.leave,
      ];
    case UserRole.financeOfficer:
      return const <_NavKey>[_NavKey.dashboard, _NavKey.payroll];
    case UserRole.payrollApprover:
      return const <_NavKey>[_NavKey.dashboard, _NavKey.payroll];
    case UserRole.employee:
      return const <_NavKey>[
        _NavKey.dashboard,
        _NavKey.employeeAttendance,
        _NavKey.leave,
        _NavKey.payroll,
      ];
    case UserRole.student:
      return const <_NavKey>[_NavKey.dashboard, _NavKey.studentAttendance];
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controllers});

  final AppControllers controllers;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Only role/sign-in state (owned by AuthController) affects navigation
    // here, so that is all this needs to listen to.
    return AnimatedBuilder(
      animation: widget.controllers.auth,
      builder: (BuildContext context, Widget? child) {
        final AppUser user = widget.controllers.auth.currentUser!;
        final List<_NavKey> keys = _keysForRole(user.role);
        final int selectedIndex = _selectedIndex.clamp(0, keys.length - 1).toInt();
        final List<Widget> pages =
            keys.map((_NavKey key) => _navSpecs[key]!.builder(widget.controllers)).toList();

        final Widget appBarActions = Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              tooltip: 'Profile',
              icon: const Icon(Icons.person_outline),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProfileScreen(controllers: widget.controllers),
                ),
              ),
            ),
          ],
        );

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool wide = constraints.maxWidth >= 900;

            if (wide) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('BCI Integrated Management System'),
                  actions: <Widget>[appBarActions],
                ),
                body: Row(
                  children: <Widget>[
                    NavigationRail(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (int index) {
                        setState(() => _selectedIndex = index);
                      },
                      labelType: NavigationRailLabelType.all,
                      destinations: keys
                          .map((_NavKey key) => NavigationRailDestination(
                                icon: Icon(_navSpecs[key]!.icon),
                                selectedIcon: Icon(_navSpecs[key]!.selectedIcon),
                                label: Text(_navSpecs[key]!.label),
                              ))
                          .toList(),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: pages[selectedIndex]),
                  ],
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('BCI Management System'),
                actions: <Widget>[appBarActions],
              ),
              body: pages[selectedIndex],
              bottomNavigationBar: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() => _selectedIndex = index);
                },
                destinations: keys
                    .map((_NavKey key) => NavigationDestination(
                          icon: Icon(_navSpecs[key]!.icon),
                          selectedIcon: Icon(_navSpecs[key]!.selectedIcon),
                          label: _navSpecs[key]!.label,
                        ))
                    .toList(),
              ),
            );
          },
        );
      },
    );
  }
}
