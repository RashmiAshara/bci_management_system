/// Shared formatting helpers used across the screens, so date and currency
/// display stays consistent without every screen re-implementing it.
extension DateFormatting on DateTime {
  /// Formats this date as `YYYY-MM-DD`.
  String toDisplayDate() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  /// Whether this date falls on the same calendar day as [other].
  bool isSameDate(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}

extension CurrencyFormatting on double {
  /// Formats this amount as an LKR currency string, e.g. `LKR 1250.00`.
  String toCurrency() => 'LKR ${toStringAsFixed(2)}';
}
