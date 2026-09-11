import 'package:flutter/material.dart';

import '../controllers/employee_controller.dart';
import '../models/employee.dart';
import '../models/salary_component.dart';
import '../utils/formatters.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/form_entry_field.dart';
import '../widgets/management_list_header.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key, required this.employees});

  final EmployeeController employees;

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final List<Employee> employees = widget.employees.employees.where((Employee employee) {
      final String search = _query.toLowerCase();
      return employee.id.toLowerCase().contains(search) ||
          employee.name.toLowerCase().contains(search) ||
          employee.department.toLowerCase().contains(search) ||
          employee.designation.toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      body: Column(
        children: <Widget>[
          ManagementListHeader(
            title: 'Employee Management',
            searchLabel: 'Search employees',
            searchHint: 'Search by ID, name, department or designation',
            onSearchChanged: (String value) => setState(() => _query = value),
          ),
          Expanded(
            child: employees.isEmpty
                ? const Center(child: Text('No employees found.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    itemCount: employees.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final Employee employee = employees[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                employee.active ? null : Theme.of(context).disabledColor,
                            child: const Icon(Icons.badge_outlined),
                          ),
                          title: Text(
                            employee.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${employee.id} • ${employee.designation}\n'
                            '${employee.department}${employee.active ? '' : ' • Inactive'}\n'
                            'Net salary: ${employee.netSalary.toCurrency()}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (String value) {
                              if (value == 'edit') {
                                _showEmployeeFormDialog(existing: employee);
                              } else if (value == 'delete') {
                                _confirmDelete(employee);
                              }
                            },
                            itemBuilder: (_) => const <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                              PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEmployeeFormDialog(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Employee'),
      ),
    );
  }

  Future<void> _confirmDelete(Employee employee) async {
    final bool confirmed = await confirmDelete(
      context,
      title: 'Delete employee',
      message: 'Delete ${employee.name} from the system?',
    );

    if (confirmed) {
      widget.employees.removeEmployee(employee.id);
    }
  }

  Future<void> _showEmployeeFormDialog({Employee? existing}) async {
    final bool isEdit = existing != null;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController idController = TextEditingController(text: existing?.id ?? '');
    final TextEditingController nameController = TextEditingController(text: existing?.name ?? '');
    final TextEditingController departmentController =
        TextEditingController(text: existing?.department ?? '');
    final TextEditingController designationController =
        TextEditingController(text: existing?.designation ?? '');
    final TextEditingController basicController =
        TextEditingController(text: existing?.basicSalary.toStringAsFixed(2) ?? '');
    final TextEditingController overtimeController =
        TextEditingController(text: (existing?.overtime ?? 0).toStringAsFixed(2));
    final TextEditingController taxController =
        TextEditingController(text: (existing?.tax ?? 0).toStringAsFixed(2));
    bool active = existing?.active ?? true;

    final List<_ComponentRow> allowanceRows = (existing?.allowances ?? const <SalaryComponent>[])
        .map((SalaryComponent c) => _ComponentRow.fromComponent(c))
        .toList();
    final List<_ComponentRow> deductionRows = (existing?.deductions ?? const <SalaryComponent>[])
        .map((SalaryComponent c) => _ComponentRow.fromComponent(c))
        .toList();

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext dialogContext, StateSetter setDialogState) {
          return AlertDialog(
            title: Text(isEdit ? 'Edit Employee' : 'Add Employee'),
            content: SizedBox(
              width: 560,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      FormEntryField(
                          controller: idController, label: 'Employee ID', enabled: !isEdit),
                      FormEntryField(controller: nameController, label: 'Full Name'),
                      FormEntryField(controller: departmentController, label: 'Department'),
                      FormEntryField(controller: designationController, label: 'Designation'),
                      FormEntryField(
                        controller: basicController,
                        label: 'Basic Salary (LKR)',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: _amountValidator,
                      ),
                      FormEntryField(
                        controller: overtimeController,
                        label: 'Overtime (LKR)',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: _amountValidator,
                      ),
                      FormEntryField(
                        controller: taxController,
                        label: 'Tax (LKR)',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: _amountValidator,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: active,
                        title: const Text('Active employee'),
                        onChanged: (bool value) => setDialogState(() => active = value),
                      ),
                      const Divider(height: 24),
                      _ComponentListEditor(
                        title: 'Allowances',
                        rows: allowanceRows,
                        onAdd: () => setDialogState(() => allowanceRows.add(_ComponentRow.empty())),
                        onRemove: (int index) =>
                            setDialogState(() => allowanceRows.removeAt(index)),
                      ),
                      const SizedBox(height: 16),
                      _ComponentListEditor(
                        title: 'Other Deductions',
                        rows: deductionRows,
                        onAdd: () => setDialogState(() => deductionRows.add(_ComponentRow.empty())),
                        onRemove: (int index) =>
                            setDialogState(() => deductionRows.removeAt(index)),
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
                    final Employee employee = Employee(
                      id: idController.text.trim(),
                      name: nameController.text.trim(),
                      department: departmentController.text.trim(),
                      designation: designationController.text.trim(),
                      basicSalary: double.parse(basicController.text.trim()),
                      overtime: double.tryParse(overtimeController.text.trim()) ?? 0,
                      tax: double.tryParse(taxController.text.trim()) ?? 0,
                      allowances: allowanceRows.map((_ComponentRow r) => r.toComponent()).toList(),
                      deductions: deductionRows.map((_ComponentRow r) => r.toComponent()).toList(),
                      active: active,
                    );
                    if (isEdit) {
                      widget.employees.updateEmployee(employee);
                    } else {
                      widget.employees.addEmployee(employee);
                    }
                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    idController.dispose();
    nameController.dispose();
    departmentController.dispose();
    designationController.dispose();
    basicController.dispose();
    overtimeController.dispose();
    taxController.dispose();
    for (final _ComponentRow row in <_ComponentRow>[...allowanceRows, ...deductionRows]) {
      row.dispose();
    }
  }
}

class _ComponentRow {
  _ComponentRow({String name = '', String amount = ''})
      : nameController = TextEditingController(text: name),
        amountController = TextEditingController(text: amount);

  factory _ComponentRow.empty() => _ComponentRow();

  factory _ComponentRow.fromComponent(SalaryComponent component) => _ComponentRow(
        name: component.name,
        amount: component.amount.toStringAsFixed(2),
      );

  final TextEditingController nameController;
  final TextEditingController amountController;

  SalaryComponent toComponent() => SalaryComponent(
        name: nameController.text.trim().isEmpty ? 'Other' : nameController.text.trim(),
        amount: double.tryParse(amountController.text.trim()) ?? 0,
      );

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class _ComponentListEditor extends StatelessWidget {
  const _ComponentListEditor({
    required this.title,
    required this.rows,
    required this.onAdd,
    required this.onRemove,
  });

  final String title;
  final List<_ComponentRow> rows;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add item'),
            ),
          ],
        ),
        for (int i = 0; i < rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: rows[i].nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: rows[i].amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onRemove(i),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
              ],
            ),
          ),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'No items added.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

/// Validator shared by the salary amount fields above: required, and must
/// parse as a number.
String? _amountValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required.';
  }
  if (double.tryParse(value.trim()) == null) {
    return 'Enter a valid numerical amount.';
  }
  return null;
}
