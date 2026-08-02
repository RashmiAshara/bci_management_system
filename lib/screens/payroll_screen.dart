import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/employee.dart';
import '../models/payroll_period.dart';
import '../models/payslip.dart';
import '../models/salary_component.dart';
import '../state/bci_store.dart';
import '../widgets/status_chip.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key, required this.store});

  final BciStore store;

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  @override
  Widget build(BuildContext context) {
    final AppUser? user = widget.store.currentUser;
    final bool isEmployeeView = user?.role == UserRole.employee;

    if (isEmployeeView) {
      return _buildEmployeeView(context, user!.employeeId);
    }
    return _buildManageView(context, user);
  }

  Widget _buildEmployeeView(BuildContext context, String? employeeId) {
    if (employeeId == null) {
      return const Center(child: Text('No linked employee record for this account.'));
    }
    final List<Payslip> payslips = widget.store.payslipsForEmployee(employeeId);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: <Widget>[
        Text(
          'My Payslips',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text('Payroll history and salary breakdown', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 18),
        if (payslips.isEmpty)
          const Center(child: Text('No payslips released yet.'))
        else
          ...payslips.map((Payslip payslip) => _payslipTile(context, payslip)),
      ],
    );
  }

  Widget _buildManageView(BuildContext context, AppUser? user) {
    final bool canGenerate = user?.role == UserRole.financeOfficer || user?.role == UserRole.admin;
    final bool canApprove = user?.role == UserRole.payrollApprover || user?.role == UserRole.admin;
    final List<PayrollPeriod> periods = widget.store.payrollPeriods;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: <Widget>[
          Text(
            'Payroll Management',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Monthly payroll periods, generation and approval',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.payments_outlined, size: 38),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('Current Estimated Net Payroll'),
                        Text(
                          _money(widget.store.monthlyPayrollTotal),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (periods.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Center(child: Text('No payroll periods created yet.')),
            )
          else
            ...periods.map(
              (PayrollPeriod period) => _periodCard(
                context,
                period,
                canGenerate: canGenerate,
                canApprove: canApprove,
              ),
            ),
        ],
      ),
      floatingActionButton: canGenerate
          ? FloatingActionButton.extended(
              onPressed: () => _showCreatePeriodDialog(context),
              icon: const Icon(Icons.add_chart_outlined),
              label: const Text('New Period'),
            )
          : null,
    );
  }

  Widget _periodCard(
    BuildContext context,
    PayrollPeriod period, {
    required bool canGenerate,
    required bool canApprove,
  }) {
    final List<Payslip> payslips = widget.store.payslipsForPeriod(period.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: const Icon(Icons.calendar_month_outlined),
        title: Text(period.label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${_formatDate(period.startDate)} to ${_formatDate(period.endDate)}'),
        trailing: StatusChip(label: period.status.label, tone: _toneForPeriod(period.status)),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if (canGenerate && period.status == PayrollPeriodStatus.draft)
                FilledButton.icon(
                  onPressed: () => widget.store.generatePayroll(period.id),
                  icon: const Icon(Icons.calculate_outlined, size: 18),
                  label: const Text('Generate Payroll'),
                ),
              if (canApprove && period.status == PayrollPeriodStatus.generated) ...<Widget>[
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => widget.store.approvePayrollPeriod(period.id),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Approve Payroll'),
                ),
              ],
            ],
          ),
          if (payslips.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Payroll has not been generated for this period yet.'),
            )
          else
            ...payslips.map((Payslip payslip) => _payslipTile(context, payslip)),
        ],
      ),
    );
  }

  Widget _payslipTile(BuildContext context, Payslip payslip) {
    final Employee? employee = widget.store.employeeById(payslip.employeeId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
        title: Text(employee?.name ?? payslip.employeeId),
        subtitle: Text('Net salary: ${_money(payslip.netSalary)}'),
        trailing: StatusChip(label: payslip.status.label, tone: _toneForPayslip(payslip.status)),
        onTap: () => _showPayslipDetail(context, payslip, employee),
      ),
    );
  }

  Future<void> _showPayslipDetail(BuildContext context, Payslip payslip, Employee? employee) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text('Payslip • ${employee?.name ?? payslip.employeeId}'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _payLine('Basic Salary', payslip.basicSalary),
                const Divider(),
                Text('Earnings', style: Theme.of(context).textTheme.labelLarge),
                for (final SalaryComponent c in payslip.earnings) _payLine(c.name, c.amount),
                const Divider(),
                _payLine('Gross Salary', payslip.grossSalary, bold: true),
                const SizedBox(height: 10),
                Text('Deductions', style: Theme.of(context).textTheme.labelLarge),
                for (final SalaryComponent c in payslip.deductions) _payLine(c.name, c.amount),
                const Divider(),
                _payLine('Net Salary', payslip.netSalary, bold: true),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _payLine(String label, double value, {bool bold = false}) {
    final TextStyle? style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: style)),
          Text(_money(value), style: style),
        ],
      ),
    );
  }

  Future<void> _showCreatePeriodDialog(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController labelController = TextEditingController();
    DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext dialogContext, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Create Payroll Period'),
            content: SizedBox(
              width: 420,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: labelController,
                      decoration: const InputDecoration(
                        labelText: 'Period label (e.g. August 2026)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Period label is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: dialogContext,
                                initialDate: startDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  startDate = picked;
                                  if (endDate.isBefore(startDate)) endDate = startDate;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today_outlined, size: 16),
                            label: Text('From ${_formatDate(startDate)}'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: dialogContext,
                                initialDate: endDate,
                                firstDate: startDate,
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setDialogState(() => endDate = picked);
                              }
                            },
                            icon: const Icon(Icons.calendar_today_outlined, size: 16),
                            label: Text('To ${_formatDate(endDate)}'),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                    widget.store.createPayrollPeriod(
                      label: labelController.text.trim(),
                      startDate: startDate,
                      endDate: endDate,
                    );
                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );

    labelController.dispose();
  }

  String _money(double value) => 'LKR ${value.toStringAsFixed(2)}';

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  StatusTone _toneForPeriod(PayrollPeriodStatus status) {
    switch (status) {
      case PayrollPeriodStatus.draft:
        return StatusTone.neutral;
      case PayrollPeriodStatus.generated:
        return StatusTone.warning;
      case PayrollPeriodStatus.approved:
        return StatusTone.positive;
    }
  }

  StatusTone _toneForPayslip(PayslipStatus status) {
    switch (status) {
      case PayslipStatus.generated:
        return StatusTone.warning;
      case PayslipStatus.approved:
        return StatusTone.positive;
    }
  }
}
