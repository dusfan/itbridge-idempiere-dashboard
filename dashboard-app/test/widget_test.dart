import 'package:dashboard_app/dashboard_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the dashboard title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const DashboardPage(),
      ),
    );

    expect(find.text('Tableau de bord'), findsOneWidget);
  });
}
