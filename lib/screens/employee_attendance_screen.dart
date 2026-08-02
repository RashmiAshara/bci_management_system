import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/attendance_status.dart';
import '../models/employee.dart';
import '../models/employee_attendance_record.dart';
import '../state/bci_store.dart';
import '../widgets/status_chip.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  const EmployeeAttendanceScreen({super.key, required this.store});

  final BciStore store;

  @override
  State<EmployeeAttendanceScreen> createState() => _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final AppUser? user = widget.store.currentUser;
    final bool isEmployeeView = user?.role == UserRole.employee;

    if (isEmployeeView) {
      return _buildSelfView(context, user!.employeeId);
    }
    return _buildStaffView(context);
  }

  Widget _buildSelfView(BuildContext context, String? employeeId) {
    if (employeeId == null) {
      return const Center(child: Text('No linked employee record for this account.'));
    }
    final List<EmployeeAttendanceRecord> records = widget.store.attendanceForEmployee(employeeId);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: <Widget>[
          Text(
            'My Attendance',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text('Daily check-in and check-out log', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 18),
          if (records.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: Text('No attendance recorded yet.')),
            )
          else
            ...records.map((EmployeeAttendanceRecord r) => _recordTile(r)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMarkDialog(
          employeeId: employeeId,
          date: DateTime.now(),
          existing: _recordFor(employeeId, DateTime.now()),
        ),
        icon: const Icon(Icons.punch_clock_outlined),
        label: const Text("Mark Today"),
      ),
    );
  }

  Widget _buildStaffView(BuildContext context) {
    final List<Employee> employees = widget.store.employees;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: <Widget>[
          Text(
            'Employee Attendance',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text('Daily attendance log for all staff', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(_formatDate(_selectedDate)),
          ),
          const SizedBox(height: 14),
          ...employees.map((Employee employee) => _employeeRow(employee)),
        ],
      ),
    );
  }

  Widget _employeeRow(Employee employee) {
    final EmployeeAttendanceRecord? existing = _recordFor(employee.id, _selectedDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.badge_outlined)),
        title: Text(employee.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          existing == null
              ? '${employee.id} • ${employee.department}'
              : '${employee.id} • ${employee.department}\n'
                  '${existing.checkIn ?? '-'} to ${existing.checkOut ?? '-'}',
        ),
        isThreeLine: existing != null,
        trailing: existing == null
            ? OutlinedButton(
                onPressed: () => _showMarkDialog(employeeId: employee.id, date: _selectedDate),
                child: const Text('Mark'),
              )
            : StatusChip(label: existing.status.label, tone: _toneFor(existing.status)),
        onTap: () =>
            _showMarkDialog(employeeId: employee.id, date: _selectedDate, existing: existing),
      ),
    );
  }

  Widget _recordTile(EmployeeAttendanceRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.event_outlined),
        title: Text(_formatDate(record.date)),
        subtitle: Text('${record.checkIn ?? '-'} to ${record.checkOut ?? '-'}'),
        trailing: StatusChip(label: record.status.label, tone: _toneFor(record.status)),
        onTap: () => _showMarkDialog(
          employeeId: record.employeeId,
          date: record.date,
          existing: record,
        ),
      ),
    );
  }

  EmployeeAttendanceRecord? _recordFor(String employeeId, DateTime date) {
    for (final EmployeeAttendanceRecord r in widget.store.employeeAttendance) {
      if (r.employeeId == employeeId && _isSameDay(r.date, date)) return r;
    }
    return null;
  }

  Future<void> _showMarkDialog({
    required String employeeId,
    required DateTime date,
    EmployeeAttendanceRecord? existing,
  }) async {
    AttendanceStatus status = existing?.status ?? AttendanceStatus.present;
    final TextEditingController checkInController =
        TextEditingController(text: existing?.checkIn ?? '');
    final TextEditingController checkOutController =
        TextEditingController(text: existing?.checkOut ?? '');

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext dialogContext, StateSetter setDialogState) {
          return AlertDialog(
            title: Text('Attendance • ${_formatDate(date)}'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DropdownButtonFormField<AttendanceStatus>(
                    value: status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: AttendanceStatus.values
                        .map((AttendanceStatus s) =>
                            DropdownMenuItem<AttendanceStatus>(value: s, child: Text(s.label)))
                        .toList(),
                    onChanged: (AttendanceStatus? v) {
                      if (v != null) setDialogState(() => status = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: checkInController,
                    decoration: const InputDecoration(
                      labelText: 'Check-in (e.g. 08:30)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: checkOutController,
                    decoration: const InputDecoration(
                      labelText: 'Check-out (e.g. 17:00)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  widget.store.markEmployeeAttendance(
                    employeeId: employeeId,
                    date: date,
                    status: status,
                    checkIn: checkInController.text.trim().isEmpty
                        ? null
                        : checkInController.text.trim(),
                    checkOut: checkOutController.text.trim().isEmpty
                        ? null
                        : checkOutController.text.trim(),
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    checkInController.dispose();
    checkOutController.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  StatusTone _toneFor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return StatusTone.positive;
      case AttendanceStatus.absent:
        return StatusTone.negative;
      case AttendanceStatus.late:
        return StatusTone.warning;
      case AttendanceStatus.excused:
        return StatusTone.neutral;
    }
  }
}
