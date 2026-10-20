import 'package:flutter_test/flutter_test.dart';

import 'package:ccis_clearance/models/clearance_models.dart';
import 'package:ccis_clearance/state/clearance_controller.dart';

void main() {
  test('administrator account creation is audited', () {
    final controller = ClearanceController.demo();
    controller.signIn(
      role: UserRole.admin,
      username: 'admin',
      password: 'demo',
    );

    final created = controller.createPersonnel(
      firstName: 'Paolo',
      middleInitial: 'D',
      lastName: 'Garcia',
    );

    expect(created, isTrue);
    expect(controller.personnel.first.displayName, 'Paolo D. Garcia');
    expect(controller.auditLog.first.action, 'Create personnel');
  });

  test('personnel requirement updates refresh clearance progress', () {
    final controller = ClearanceController.demo();
    controller.signIn(
      role: UserRole.personnel,
      username: 'personnel',
      password: 'demo',
    );
    final before = controller.selectedStudent.clearanceProgress;

    final updated = controller.updateRequirement(
      requirementId: 'ccis-information-sheet',
      status: RequirementStatus.verified,
      note: 'Checked for demonstration.',
    );

    expect(updated, isTrue);
    expect(controller.selectedStudent.clearanceProgress, greaterThan(before));
    expect(
        controller.notifications.first.title, 'CCIS information sheet updated');
  });
}
