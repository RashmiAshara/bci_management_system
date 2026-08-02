import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/course.dart';
import '../models/employee.dart';
import '../models/student.dart';
import '../state/bci_store.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.store});

  final BciStore store;

  @override
  Widget build(BuildContext context) {
    final AppUser? user = store.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final Employee? linkedEmployee =
        user.employeeId == null ? null : store.employeeById(user.employeeId!);
    final Student? linkedStudent =
        user.studentId == null ? null : store.studentById(user.studentId!);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 32,
                    child: Text(
                      user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(user.email),
                        const SizedBox(height: 6),
                        Chip(label: Text(user.role.label)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (linkedEmployee != null) ...<Widget>[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Employment Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(label: 'Employee ID', value: linkedEmployee.id),
                    _InfoRow(label: 'Department', value: linkedEmployee.department),
                    _InfoRow(label: 'Designation', value: linkedEmployee.designation),
                  ],
                ),
              ),
            ),
          ],
          if (linkedStudent != null) ...<Widget>[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Student Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(label: 'Student ID', value: linkedStudent.id),
                    _InfoRow(label: 'Programme', value: linkedStudent.program),
                    _InfoRow(label: 'Intake', value: linkedStudent.intake),
                    _InfoRow(label: 'Status', value: linkedStudent.status),
                    const SizedBox(height: 10),
                    const Text(
                      'Enrolled Courses',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Builder(builder: (BuildContext context) {
                      final List<Course> myCourses =
                          store.coursesForStudent(linkedStudent.id);
                      if (myCourses.isEmpty) {
                        return const Text(
                          'Not enrolled in any courses yet.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        );
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: myCourses
                            .map((Course course) => Chip(
                                  label: Text('${course.code} - ${course.name}'),
                                ))
                            .toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              store.logout();
              Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
