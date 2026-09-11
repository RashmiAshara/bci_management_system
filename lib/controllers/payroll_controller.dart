import 'package:flutter/foundation.dart';

import '../models/employee.dart';
import '../models/leave_request.dart';
import '../models/payroll_period.dart';
import '../models/payslip.dart';
import '../models/salary_component.dart';
import 'employee_controller.dart';
import 'leave_controller.dart';

/// Controller for payroll periods and generated payslips. Depends on
/// [EmployeeController] (for the active roster) and [LeaveController]
/// (for no-pay leave taken in a period) to generate payroll.
class PayrollController extends ChangeNotifier {
  PayrollController(this._employees, this._leave);

  final EmployeeController _employees;
  final LeaveController _leave;

  final List<PayrollPeriod> _payrollPeriods = <PayrollPeriod>[];
  final List<Payslip> _payslips = <Payslip>[];

  List<PayrollPeriod> get payrollPeriods {
    final List<PayrollPeriod> sorted = List<PayrollPeriod>.of(_payrollPeriods);
    sorted.sort((PayrollPeriod a, PayrollPeriod b) => b.startDate.compareTo(a.startDate));
    return List<PayrollPeriod>.unmodifiable(sorted);
  }

  int get pendingPayrollApprovalCount => _payrollPeriods
      .where((PayrollPeriod p) => p.status == PayrollPeriodStatus.generated)
      .length;

  void createPayrollPeriod({
    required String label,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    _payrollPeriods.add(PayrollPeriod(
      id: 'PP-${DateTime.now().microsecondsSinceEpoch}',
      label: label,
      startDate: startDate,
      endDate: endDate,
    ));
    notifyListeners();
  }

  void generatePayroll(String periodId) {
    final int periodIndex = _payrollPeriods.indexWhere((PayrollPeriod p) => p.id == periodId);
    if (periodIndex == -1) return;
    final PayrollPeriod period = _payrollPeriods[periodIndex];

    _payslips.removeWhere((Payslip p) => p.periodId == periodId);

    for (final Employee employee in _employees.activeEmployees) {
      final int noPayDays = _leave.leaveRequests
          .where((LeaveRequest r) =>
              r.employeeId == employee.id &&
              r.leaveType == LeaveType.noPay &&
              r.status == LeaveStatus.approved &&
              r.overlaps(period.startDate, period.endDate))
          .fold<int>(0, (int sum, LeaveRequest r) => sum + r.durationInDays);

      final double dailyRate = employee.basicSalary / 30;
      final double noPayDeduction = dailyRate * noPayDays;

      final List<SalaryComponent> earnings = <SalaryComponent>[
        ...employee.allowances,
        if (employee.overtime > 0) SalaryComponent(name: 'Overtime', amount: employee.overtime),
      ];

      final List<SalaryComponent> deductions = <SalaryComponent>[
        ...employee.deductions,
        if (employee.tax > 0) SalaryComponent(name: 'Tax', amount: employee.tax),
        if (noPayDeduction > 0)
          SalaryComponent(name: 'No-Pay Leave ($noPayDays day(s))', amount: noPayDeduction),
      ];

      _payslips.add(Payslip(
        id: 'PS-$periodId-${employee.id}',
        periodId: periodId,
        employeeId: employee.id,
        basicSalary: employee.basicSalary,
        earnings: earnings,
        deductions: deductions,
      ));
    }

    _payrollPeriods[periodIndex] = period.copyWith(status: PayrollPeriodStatus.generated);
    notifyListeners();
  }

  void approvePayrollPeriod(String periodId) {
    final int periodIndex = _payrollPeriods.indexWhere((PayrollPeriod p) => p.id == periodId);
    if (periodIndex == -1) return;
    _payrollPeriods[periodIndex] =
        _payrollPeriods[periodIndex].copyWith(status: PayrollPeriodStatus.approved);

    for (int i = 0; i < _payslips.length; i++) {
      if (_payslips[i].periodId == periodId) {
        _payslips[i] = _payslips[i].copyWith(status: PayslipStatus.approved);
      }
    }
    notifyListeners();
  }

  List<Payslip> payslipsForPeriod(String periodId) =>
      _payslips.where((Payslip p) => p.periodId == periodId).toList();

  List<Payslip> payslipsForEmployee(String employeeId) =>
      _payslips.where((Payslip p) => p.employeeId == employeeId).toList();
}
