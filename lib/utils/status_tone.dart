import '../models/attendance_status.dart';
import '../models/leave_request.dart';
import '../models/payroll_period.dart';
import '../models/payslip.dart';
import '../widgets/status_chip.dart';

/// Maps each status enum to the [StatusTone] its [StatusChip] should use,
/// so the mapping lives in one place instead of being re-switched on in
/// every screen that displays one of these statuses.
extension AttendanceStatusTone on AttendanceStatus {
  StatusTone get tone {
    switch (this) {
      case AttendanceStatus.present:
        return StatusTone.positive;
      case AttendanceStatus.absent:
        return StatusTone.negative;
      case AttendanceStatus.late:
        return StatusTone.warning;
      case AttendanceStatus.excused:
        return StatusTone.neutral;
    }
  }
}

extension LeaveStatusTone on LeaveStatus {
  StatusTone get tone {
    switch (this) {
      case LeaveStatus.approved:
        return StatusTone.positive;
      case LeaveStatus.rejected:
        return StatusTone.negative;
      case LeaveStatus.pending:
        return StatusTone.warning;
    }
  }
}

extension PayrollPeriodStatusTone on PayrollPeriodStatus {
  StatusTone get tone {
    switch (this) {
      case PayrollPeriodStatus.draft:
        return StatusTone.neutral;
      case PayrollPeriodStatus.generated:
        return StatusTone.warning;
      case PayrollPeriodStatus.approved:
        return StatusTone.positive;
    }
  }
}

extension PayslipStatusTone on PayslipStatus {
  StatusTone get tone {
    switch (this) {
      case PayslipStatus.generated:
        return StatusTone.warning;
      case PayslipStatus.approved:
        return StatusTone.positive;
    }
  }
}
