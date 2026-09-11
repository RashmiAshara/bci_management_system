import 'package:flutter/material.dart';

import '../utils/formatters.dart';
import 'date_picker_button.dart';

/// A "From"/"To" pair of [DatePickerButton]s, used by the leave application
/// and payroll period dialogs to pick a date range. The end date picker
/// never allows a date before [startDate].
class DateRangePickerRow extends StatelessWidget {
  const DateRangePickerRow({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTime> onStartChanged;
  final ValueChanged<DateTime> onEndChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: DatePickerButton(
            date: startDate,
            iconSize: 16,
            label: 'From ${startDate.toDisplayDate()}',
            onChanged: onStartChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DatePickerButton(
            date: endDate,
            firstDate: startDate,
            iconSize: 16,
            label: 'To ${endDate.toDisplayDate()}',
            onChanged: onEndChanged,
          ),
        ),
      ],
    );
  }
}
