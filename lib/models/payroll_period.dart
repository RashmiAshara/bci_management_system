enum PayrollPeriodStatus { draft, generated, approved }

extension PayrollPeriodStatusLabel on PayrollPeriodStatus {
  String get label {
    switch (this) {
      case PayrollPeriodStatus.draft:
        return 'Draft';
      case PayrollPeriodStatus.generated:
        return 'Generated';
      case PayrollPeriodStatus.approved:
        return 'Approved';
    }
  }
}

class PayrollPeriod {
  const PayrollPeriod({
    required this.id,
    required this.label,
    required this.startDate,
    required this.endDate,
    this.status = PayrollPeriodStatus.draft,
  });

  final String id;
  final String label;
  final DateTime startDate;
  final DateTime endDate;
  final PayrollPeriodStatus status;

  PayrollPeriod copyWith({PayrollPeriodStatus? status}) {
    return PayrollPeriod(
      id: id,
      label: label,
      startDate: startDate,
      endDate: endDate,
      status: status ?? this.status,
    );
  }
}
