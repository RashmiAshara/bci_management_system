import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/employee_controller.dart';
import '../controllers/leave_controller.dart';
import '../models/app_user.dart';
import '../models/employee.dart';
import '../models/leave_request.dart';
import '../utils/formatters.dart';
import '../utils/status_tone.dart';
import '../widgets/date_range_picker_row.dart';
import '../widgets/status_chip.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({
    super.key,
    required this.auth,
    required this.leave,
    required this.employees,
  });

  final AuthController auth;
  final LeaveController leave;
  final EmployeeController employees;

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  @override
  Widget build(BuildContext context) {
    final AppUser? user = widget.auth.currentUser;
    final bool canApprove = user?.role == UserRole.hrOfficer || user?.role == UserRole.admin;
    final bool isEmployeeView = user?.role == UserRole.employee && !canApprove;

    if (isEmployeeView) {
      return _buildSelfView(context, user!.employeeId);
    }
    return _buildManageView(context, canApprove: canApprove);
  }

  Widget _buildSelfView(BuildContext context, String? employeeId) {
    if (employeeId == null) {
      return const Center(child: Text('No linked employee record for this account.'));
    }
    final List<LeaveRequest> requests = widget.leave.leaveRequestsForEmployee(employeeId);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: <Widget>[
          Text(
            'My Leave',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text('Leave balance and request history', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: LeaveType.values
                .where((LeaveType t) => t != LeaveType.noPay)
                .map((LeaveType type) => Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(type.label, style: Theme.of(context).textTheme.labelLarge),
                            Text(
                              '${widget.leave.leaveBalance(employeeId, type)} day(s) left',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          if (requests.isEmpty)
            const Center(child: Text('No leave requests yet.'))
          else
            ...requests.map((LeaveRequest r) => _requestTile(context, r, canApprove: false)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showApplyDialog(employeeId),
        icon: const Icon(Icons.event_available_outlined),
        label: const Text('Apply for Leave'),
      ),
    );
  }

  Widget _buildManageView(BuildContext context, {required bool canApprove}) {
    final List<LeaveRequest> requests = List<LeaveRequest>.of(widget.leave.leaveRequests)
      ..sort((LeaveRequest a, LeaveRequest b) {
        if (a.status == b.status) return b.appliedOn.compareTo(a.appliedOn);
        if (a.status == LeaveStatus.pending) return -1;
        if (b.status == LeaveStatus.pending) return 1;
        return b.appliedOn.compareTo(a.appliedOn);
      });

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: <Widget>[
          Text(
            'Leave Requests',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Employee leave applications and approvals',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          if (requests.isEmpty)
            const Center(child: Text('No leave requests submitted yet.'))
          else
            ...requests.map((LeaveRequest r) => _requestTile(context, r, canApprove: canApprove)),
        ],
      ),
    );
  }

  Widget _requestTile(BuildContext context, LeaveRequest request, {required bool canApprove}) {
    final Employee? employee = widget.employees.employeeById(request.employeeId);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    employee?.name ?? request.employeeId,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                StatusChip(label: request.status.label, tone: request.status.tone),
              ],
            ),
            const SizedBox(height: 4),
            Text('${request.leaveType.label} • ${request.durationInDays} day(s)'),
            Text(
              '${request.startDate.toDisplayDate()} to ${request.endDate.toDisplayDate()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (request.reason.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(request.reason, style: Theme.of(context).textTheme.bodySmall),
            ],
            if (canApprove && request.status == LeaveStatus.pending) ...<Widget>[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => widget.leave.rejectLeave(request.id),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => widget.leave.approveLeave(request.id),
                    child: const Text('Approve'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showApplyDialog(String employeeId) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController reasonController = TextEditingController();
    LeaveType leaveType = LeaveType.annual;
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext dialogContext, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Apply for Leave'),
            content: SizedBox(
              width: 460,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      DropdownButtonFormField<LeaveType>(
                        value: leaveType,
                        decoration: const InputDecoration(
                          labelText: 'Leave Type',
                          border: OutlineInputBorder(),
                        ),
                        items: LeaveType.values
                            .map((LeaveType t) =>
                                DropdownMenuItem<LeaveType>(value: t, child: Text(t.label)))
                            .toList(),
                        onChanged: (LeaveType? v) {
                          if (v != null) setDialogState(() => leaveType = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      DateRangePickerRow(
                        startDate: startDate,
                        endDate: endDate,
                        onStartChanged: (DateTime picked) => setDialogState(() {
                          startDate = picked;
                          if (endDate.isBefore(startDate)) endDate = startDate;
                        }),
                        onEndChanged: (DateTime picked) => setDialogState(() => endDate = picked),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: reasonController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Reason',
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Reason is required.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    widget.leave.applyLeave(
                      employeeId: employeeId,
                      leaveType: leaveType,
                      startDate: startDate,
                      endDate: endDate,
                      reason: reasonController.text.trim(),
                    );
                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );

    reasonController.dispose();
  }
}
