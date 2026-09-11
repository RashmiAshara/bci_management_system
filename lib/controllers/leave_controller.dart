import 'package:flutter/foundation.dart';

import '../models/leave_request.dart';

/// Controller for leave applications, balances and approvals.
class LeaveController extends ChangeNotifier {
  static const Map<LeaveType, int> leaveEntitlement = <LeaveType, int>{
    LeaveType.annual: 14,
    LeaveType.casual: 7,
    LeaveType.medical: 7,
    LeaveType.noPay: 0,
  };

  final List<LeaveRequest> _leaveRequests = <LeaveRequest>[];

  List<LeaveRequest> get leaveRequests => List<LeaveRequest>.unmodifiable(_leaveRequests);

  List<LeaveRequest> leaveRequestsForEmployee(String employeeId) {
    return _leaveRequests.where((LeaveRequest r) => r.employeeId == employeeId).toList()
      ..sort((LeaveRequest a, LeaveRequest b) => b.appliedOn.compareTo(a.appliedOn));
  }

  int get pendingLeaveCount =>
      _leaveRequests.where((LeaveRequest r) => r.status == LeaveStatus.pending).length;

  int leaveBalance(String employeeId, LeaveType type) {
    final int entitlement = leaveEntitlement[type] ?? 0;
    final int used = _leaveRequests
        .where((LeaveRequest r) =>
            r.employeeId == employeeId && r.leaveType == type && r.status == LeaveStatus.approved)
        .fold<int>(0, (int sum, LeaveRequest r) => sum + r.durationInDays);
    return entitlement - used;
  }

  void applyLeave({
    required String employeeId,
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) {
    _leaveRequests.add(LeaveRequest(
      id: 'LR-${DateTime.now().microsecondsSinceEpoch}',
      employeeId: employeeId,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      appliedOn: DateTime.now(),
    ));
    notifyListeners();
  }

  void _setLeaveStatus(String id, LeaveStatus status) {
    final int index = _leaveRequests.indexWhere((LeaveRequest r) => r.id == id);
    if (index == -1) return;
    _leaveRequests[index] = _leaveRequests[index].copyWith(status: status);
    notifyListeners();
  }

  void approveLeave(String id) => _setLeaveStatus(id, LeaveStatus.approved);

  void rejectLeave(String id) => _setLeaveStatus(id, LeaveStatus.rejected);
}
