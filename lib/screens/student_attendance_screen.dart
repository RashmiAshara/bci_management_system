import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/student_attendance_controller.dart';
import '../controllers/student_controller.dart';
import '../models/app_user.dart';
import '../models/attendance_status.dart';
import '../models/module.dart';
import '../models/student.dart';
import '../models/student_attendance_record.dart';
import '../utils/formatters.dart';
import '../utils/status_tone.dart';
import '../widgets/date_picker_button.dart';
import '../widgets/status_chip.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({
    super.key,
    required this.auth,
    required this.attendance,
    required this.students,
  });

  final AuthController auth;
  final StudentAttendanceController attendance;
  final StudentController students;

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  Module? _selectedModule;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final AppUser? user = widget.auth.currentUser;
    final bool isStudentView = user?.role == UserRole.student;

    if (isStudentView) {
      return _buildStudentSelfView(context, user!.studentId);
    }

    return _buildMarkingView(context);
  }

  Widget _buildStudentSelfView(BuildContext context, String? studentId) {
    if (studentId == null) {
      return const Center(child: Text('No linked student record for this account.'));
    }
    final Student? student = widget.students.studentById(studentId);
    final List<StudentAttendanceRecord> records = widget.attendance.studentAttendance
        .where((StudentAttendanceRecord r) => r.studentId == studentId)
        .toList()
      ..sort((StudentAttendanceRecord a, StudentAttendanceRecord b) => b.date.compareTo(a.date));
    final double percentage = widget.attendance.attendancePercentage(studentId);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Text(
          'My Attendance',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(student?.name ?? studentId, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: <Widget>[
                const Icon(Icons.pie_chart_outline, size: 36),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Overall Attendance'),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (records.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: Text('No attendance records yet.')),
          )
        else
          ...records.map(
            (StudentAttendanceRecord r) => Card(
              child: ListTile(
                leading: const Icon(Icons.event_outlined),
                title: Text(widget.attendance.moduleById(r.moduleId)?.name ?? r.moduleId),
                subtitle: Text(r.date.toDisplayDate()),
                trailing: StatusChip(label: r.status.label, tone: r.status.tone),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMarkingView(BuildContext context) {
    final List<Module> modules = widget.attendance.modules;
    _selectedModule ??= modules.isEmpty ? null : modules.first;
    final List<Student> students = widget.students.students;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: <Widget>[
          Text(
            'Student Attendance',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Mark attendance by module and date',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<Module>(
                  value: _selectedModule,
                  decoration: const InputDecoration(
                    labelText: 'Module',
                    border: OutlineInputBorder(),
                  ),
                  items: modules
                      .map((Module m) => DropdownMenuItem<Module>(value: m, child: Text(m.toString())))
                      .toList(),
                  onChanged: (Module? m) => setState(() => _selectedModule = m),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DatePickerButton(
                  date: _selectedDate,
                  onChanged: (DateTime picked) => setState(() => _selectedDate = picked),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_selectedModule == null)
            const Center(child: Text('No modules configured.'))
          else
            ...students.map((Student student) => _buildStudentRow(student)),
        ],
      ),
    );
  }

  Widget _buildStudentRow(Student student) {
    final Module module = _selectedModule!;
    StudentAttendanceRecord? existing;
    for (final StudentAttendanceRecord r in widget.attendance.studentAttendance) {
      if (r.studentId == student.id && r.moduleId == module.id && r.date.isSameDate(_selectedDate)) {
        existing = r;
        break;
      }
    }
    final double percentage = widget.attendance.attendancePercentage(student.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(student.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '${student.id} • ${percentage.toStringAsFixed(0)}% overall',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AttendanceStatus.values.map((AttendanceStatus status) {
                final bool selected = existing?.status == status;
                return ChoiceChip(
                  label: Text(status.label),
                  selected: selected,
                  onSelected: (_) {
                    widget.attendance.markStudentAttendance(
                      studentId: student.id,
                      moduleId: module.id,
                      date: _selectedDate,
                      status: status,
                    );
                    setState(() {});
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
