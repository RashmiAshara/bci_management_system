enum LeaveType { annual, casual, medical, noPay }

extension LeaveTypeLabel on LeaveType {
  String get label {
    switch (this) {
      case LeaveType.annual:
        return 'Annual';
      case LeaveType.casual:
        return 'Casual';
      case LeaveType.medical:
        return 'Medical';
      case LeaveType.noPay:
        return 'No-Pay';
    }
  }
}

enum LeaveStatus { pending, approved, rejected }

extension LeaveStatusLabel on LeaveStatus {
  String get label {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
    }
  }
}

class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.appliedOn,
    this.status = LeaveStatus.pending,
  });

  final String id;
  final String employeeId;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final DateTime appliedOn;
  final LeaveStatus status;

  int get durationInDays => endDate.difference(startDate).inDays + 1;

  bool overlaps(DateTime rangeStart, DateTime rangeEnd) {
    return !endDate.isBefore(rangeStart) && !startDate.isAfter(rangeEnd);
  }

  LeaveRequest copyWith({LeaveStatus? status}) {
    return LeaveRequest(
      id: id,
      employeeId: employeeId,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      appliedOn: appliedOn,
      status: status ?? this.status,
    );
  }
}
