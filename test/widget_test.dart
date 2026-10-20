import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:ccis_clearance/main.dart';
import 'package:ccis_clearance/state/clearance_controller.dart';

void main() {
  testWidgets('shows the CCIS CLEARANCE sign-in experience', (tester) async {
    await tester
        .pumpWidget(CcisClearanceApp(controller: ClearanceController.demo()));

    expect(find.text('CCIS CLEARANCE'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in as Student'), findsOneWidget);
  });

  testWidgets('shows the student dashboard after mobile sign-in',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(552, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester
        .pumpWidget(CcisClearanceApp(controller: ClearanceController.demo()));
    await tester.enterText(find.byType(TextFormField).at(0), 'mariel');
    await tester.enterText(find.byType(TextFormField).at(1), 'demo-pass');
    await tester.tap(find.text('Sign in as Student'));
    await tester.pumpAndSettle();

    expect(find.text('Good morning, Mariel.'), findsOneWidget);
    expect(find.text('Your event requirements'), findsOneWidget);
  });
}
