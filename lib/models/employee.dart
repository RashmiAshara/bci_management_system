import 'salary_component.dart';

class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.department,
    required this.designation,
    required this.basicSalary,
    this.overtime = 0,
    this.tax = 0,
    this.allowances = const <SalaryComponent>[],
    this.deductions = const <SalaryComponent>[],
    this.active = true,
  });

  final String id;
  final String name;
  final String department;
  final String designation;
  final double basicSalary;
  final double overtime;
  final double tax;
  final List<SalaryComponent> allowances;
  final List<SalaryComponent> deductions;
  final bool active;

  double get totalAllowances => totalOf(allowances);

  double get totalOtherDeductions => totalOf(deductions);

  double get grossSalary => basicSalary + totalAllowances + overtime;

  double get totalDeductions => totalOtherDeductions + tax;

  double get netSalary => grossSalary - totalDeductions;

  Employee copyWith({
    String? name,
    String? department,
    String? designation,
    double? basicSalary,
    double? overtime,
    double? tax,
    List<SalaryComponent>? allowances,
    List<SalaryComponent>? deductions,
    bool? active,
  }) {
    return Employee(
      id: id,
      name: name ?? this.name,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      basicSalary: basicSalary ?? this.basicSalary,
      overtime: overtime ?? this.overtime,
      tax: tax ?? this.tax,
      allowances: allowances ?? this.allowances,
      deductions: deductions ?? this.deductions,
      active: active ?? this.active,
    );
  }
}
