import 'package:flutter/material.dart';

import '../state/bci_store.dart';
import '../utils/formatters.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.store});

  final BciStore store;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Text(
          'BCI Management Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          store.currentUser == null
              ? 'Student administration and monthly payroll overview'
              : 'Welcome, ${store.currentUser!.name} (${store.currentUser!.role.label})',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final int columns = constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 600
                    ? 2
                    : 1;

            final double width =
                (constraints.maxWidth - ((columns - 1) * 12)) / columns;

            final List<Widget> cards = <Widget>[
              SummaryCard(
                title: 'Registered Students',
                value: store.students.length.toString(),
                subtitle: '${store.activeStudentCount} active students',
                icon: Icons.school_outlined,
              ),
              SummaryCard(
                title: 'Courses',
                value: store.courses.length.toString(),
                subtitle: '${store.enrollments.length} active enrollment(s)',
                icon: Icons.menu_book_outlined,
              ),
              SummaryCard(
                title: 'Employees',
                value: store.employees.length.toString(),
                subtitle: 'Academic and non-academic staff',
                icon: Icons.badge_outlined,
              ),
              SummaryCard(
                title: 'Monthly Net Payroll',
                value: store.monthlyPayrollTotal.toCurrency(),
                subtitle: 'Calculated from current employee records',
                icon: Icons.payments_outlined,
              ),
              SummaryCard(
                title: 'Pending Leave Requests',
                value: store.pendingLeaveCount.toString(),
                subtitle: 'Awaiting HR/admin approval',
                icon: Icons.event_busy_outlined,
              ),
              SummaryCard(
                title: 'Payroll Awaiting Approval',
                value: store.pendingPayrollApprovalCount.toString(),
                subtitle: 'Generated periods pending sign-off',
                icon: Icons.fact_check_outlined,
              ),
            ];

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: cards
                  .map((Widget card) => SizedBox(width: width, child: card))
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'MVP Modules',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                const _ModuleRow(
                  icon: Icons.people_alt_outlined,
                  title: 'Student Management',
                  description:
                      'Register, search, view and remove student records.',
                ),
                const Divider(),
                const _ModuleRow(
                  icon: Icons.menu_book_outlined,
                  title: 'Course Management & Enrollment',
                  description:
                      'Manage courses and enrol students, with each student showing their assigned courses.',
                ),
                const Divider(),
                const _ModuleRow(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Payroll Management',
                  description:
                      'Register employees and calculate gross and net salaries.',
                ),
                const Divider(),
                const _ModuleRow(
                  icon: Icons.cloud_outlined,
                  title: 'Backend Integration Ready',
                  description:
                      'Replace the in-memory store with Spring Boot REST APIs later.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(description),
    );
  }
}
