import 'package:flutter/material.dart';

import '../utils/formatters.dart';

/// An [OutlinedButton] that opens a date picker and reports the chosen
/// date via [onChanged].
class DatePickerButton extends StatelessWidget {
  const DatePickerButton({
    super.key,
    required this.date,
    required this.onChanged,
    this.label,
    this.firstDate,
    this.lastDate,
    this.iconSize,
  });

  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  final String? label;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: firstDate ?? DateTime(2020),
          lastDate: lastDate ?? DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      icon: Icon(Icons.calendar_today_outlined, size: iconSize),
      label: Text(label ?? date.toDisplayDate()),
    );
  }
}
