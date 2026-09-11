import 'package:flutter/foundation.dart';

import '../models/employee.dart';
import '../models/salary_component.dart';
import '../utils/collection_utils.dart';

/// Controller for employee records and the payroll figures derived
/// directly from them.
class EmployeeController extends ChangeNotifier {
  final List<Employee> _employees = <Employee>[
    const Employee(
      id: 'EMP-001',
      name: 'Dr. Amal Jayasinghe',
      department: 'School of Computing',
      designation: 'Senior Lecturer',
      basicSalary: 185000,
      overtime: 12000,
      tax: 17500,
      allowances: <SalaryComponent>[
        SalaryComponent(name: 'Cost of Living Allowance', amount: 20000),
        SalaryComponent(name: 'Transport Allowance', amount: 15000),
      ],
      deductions: <SalaryComponent>[
        SalaryComponent(name: 'Loan Instalment', amount: 8500),
      ],
    ),
    const Employee(
      id: 'EMP-002',
      name: 'Rashmi Perera',
      department: 'Finance',
      designation: 'Finance Officer',
      basicSalary: 125000,
      overtime: 6500,
      tax: 9500,
      allowances: <SalaryComponent>[
        SalaryComponent(name: 'Cost of Living Allowance', amount: 14000),
        SalaryComponent(name: 'Telephone Allowance', amount: 8000),
      ],
      deductions: <SalaryComponent>[
        SalaryComponent(name: 'Staff Welfare Fund', amount: 5000),
      ],
    ),
    const Employee(
      id: 'EMP-003',
      name: 'Kamal Fernando',
      department: 'Administration',
      designation: 'Management Assistant',
      basicSalary: 95000,
      overtime: 8000,
      tax: 4200,
      allowances: <SalaryComponent>[
        SalaryComponent(name: 'Transport Allowance', amount: 10000),
        SalaryComponent(name: 'Meal Allowance', amount: 8000),
      ],
      deductions: <SalaryComponent>[
        SalaryComponent(name: 'Salary Advance', amount: 3500),
      ],
    ),
  ];

  List<Employee> get employees => List<Employee>.unmodifiable(_employees);

  List<Employee> get activeEmployees =>
      _employees.where((Employee employee) => employee.active).toList();

  Employee? employeeById(String id) => findById(_employees, id, (Employee e) => e.id);

  double get monthlyPayrollTotal => _employees.fold<double>(
        0,
        (double sum, Employee employee) => sum + employee.netSalary,
      );

  void addEmployee(Employee employee) {
    _employees.add(employee);
    notifyListeners();
  }

  void updateEmployee(Employee employee) {
    final int index = _employees.indexWhere((Employee e) => e.id == employee.id);
    if (index == -1) return;
    _employees[index] = employee;
    notifyListeners();
  }

  void removeEmployee(String employeeId) {
    _employees.removeWhere((Employee employee) => employee.id == employeeId);
    notifyListeners();
  }
}
