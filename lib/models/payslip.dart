import 'salary_component.dart';

enum PayslipStatus { generated, approved }

extension PayslipStatusLabel on PayslipStatus {
  String get label {
    switch (this) {
      case PayslipStatus.generated:
        return 'Generated';
      case PayslipStatus.approved:
        return 'Approved';
    }
  }
}

class Payslip {
  const Payslip({
    required this.id,
    required this.periodId,
    required this.employeeId,
    required this.basicSalary,
    required this.earnings,
    required this.deductions,
    this.status = PayslipStatus.generated,
  });

  final String id;
  final String periodId;
  final String employeeId;
  final double basicSalary;
  final List<SalaryComponent> earnings;
  final List<SalaryComponent> deductions;
  final PayslipStatus status;

  double get grossSalary => basicSalary + totalOf(earnings);

  double get totalDeductions => totalOf(deductions);

  double get netSalary => grossSalary - totalDeductions;

  Payslip copyWith({PayslipStatus? status}) {
    return Payslip(
      id: id,
      periodId: periodId,
      employeeId: employeeId,
      basicSalary: basicSalary,
      earnings: earnings,
      deductions: deductions,
      status: status ?? this.status,
    );
  }
}
