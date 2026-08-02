import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../state/bci_store.dart';
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
  final Widget Function(BciStore store) builder;
}

final Map<_NavKey, _NavSpec> _navSpecs = <_NavKey, _NavSpec>{
  _NavKey.dashboard: _NavSpec(
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: 'Dashboard',
    builder: (BciStore store) => DashboardScreen(store: store),
  ),
  _NavKey.students: _NavSpec(
    icon: Icons.school_outlined,
    selectedIcon: Icons.school,
    label: 'Students',
    builder: (BciStore store) => StudentsScreen(store: store),
  ),
  _NavKey.courses: _NavSpec(
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book,
    label: 'Courses',
    builder: (BciStore store) => CoursesScreen(store: store),
  ),
  _NavKey.studentAttendance: _NavSpec(
    icon: Icons.fact_check_outlined,
    selectedIcon: Icons.fact_check,
    label: 'Student Attendance',
    builder: (BciStore store) => StudentAttendanceScreen(store: store),
  ),
  _NavKey.employees: _NavSpec(
    icon: Icons.badge_outlined,
    selectedIcon: Icons.badge,
    label: 'Employees',
    builder: (BciStore store) => EmployeesScreen(store: store),
  ),
  _NavKey.employeeAttendance: _NavSpec(
    icon: Icons.punch_clock_outlined,
    selectedIcon: Icons.punch_clock,
    label: 'Staff Attendance',
    builder: (BciStore store) => EmployeeAttendanceScreen(store: store),
  ),
  _NavKey.leave: _NavSpec(
    icon: Icons.event_busy_outlined,
    selectedIcon: Icons.event_busy,
    label: 'Leave',
    builder: (BciStore store) => LeaveScreen(store: store),
  ),
  _NavKey.payroll: _NavSpec(
    icon: Icons.payments_outlined,
    selectedIcon: Icons.payments,
    label: 'Payroll',
    builder: (BciStore store) => PayrollScreen(store: store),
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
  const HomeShell({super.key, required this.store});

  final BciStore store;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (BuildContext context, Widget? child) {
        final AppUser user = widget.store.currentUser!;
        final List<_NavKey> keys = _keysForRole(user.role);
        final int selectedIndex = _selectedIndex.clamp(0, keys.length - 1).toInt();
        final List<Widget> pages =
            keys.map((_NavKey key) => _navSpecs[key]!.builder(widget.store)).toList();

        final Widget appBarActions = Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              tooltip: 'Profile',
              icon: const Icon(Icons.person_outline),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProfileScreen(store: widget.store),
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
