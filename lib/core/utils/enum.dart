import 'package:collection/collection.dart';

// USER ROLES
enum UserRole {
  user(1, 'User'),
  admin(2, 'Admin'),
  facilitator(3, 'Facilitator'),
  report(4, 'Report');

  final int id;
  final String label;

  const UserRole(this.id, this.label);

  static UserRole? fromId(int id) {
    return UserRole.values.firstWhereOrNull((e) => e.id == id);
  }
}

// PROCESS STAGES
enum Stage {
  requested(20, 'Requested'),
  assignedToEsna(21, 'Assigned to ES&A'),
  assignedToInsurance(22, 'Assigned to Insurance'),
  insuranceQuoteApproval(23, 'Insurance Quote Approval'),
  emiCalculation(24, 'EMI Calculation'),
  emiApproval(25, 'EMI Approval User'),
  paymentDetails(26, 'Payment Details'),
  rtoTaxReceipt(27, 'RTO Tax Receipt'),
  employeeFeedback(28, 'Employee Feedback'),
  declarationAcceptance(29, 'Declaration Acceptance'),
  deletedByUser(110, 'Deleted by User'),
  inactive(120, 'Inactive');

  final int stageNo;
  final String label;

  const Stage(this.stageNo, this.label);

  static Stage? fromStageNo(int stageNo) {
    return Stage.values.firstWhereOrNull(
          (e) => e.stageNo == stageNo,
    );
  }
}
