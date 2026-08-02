class SalaryComponent {
  const SalaryComponent({required this.name, required this.amount});

  final String name;
  final double amount;
}

double totalOf(List<SalaryComponent> components) =>
    components.fold<double>(0, (double sum, SalaryComponent c) => sum + c.amount);
