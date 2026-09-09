import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idempiere_sales_app/core/app_strings.dart';
import 'package:idempiere_sales_app/core/theme.dart';
import 'package:idempiere_sales_app/features/auth/auth_session.dart';
import 'package:idempiere_sales_app/features/login/login_screen.dart';
import 'package:provider/provider.dart';

/// Pumps the login screen at a given surface size.
///
/// Any RenderFlex overflow raises during pump, so these cases double as
/// layout-regression cover for the two breakpoints.
Future<void> pumpLogin(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ChangeNotifierProvider<AuthSession>(
      create: (_) => AuthSession(),
      child: MaterialApp(theme: buildAppTheme(), home: const LoginScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const Size phone = Size(375, 812);
  const Size tablet = Size(1024, 1366);

  testWidgets('renders the French login card on a phone', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester, phone);

    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(find.text(AppStrings.email), findsOneWidget);
    expect(find.text(AppStrings.password), findsOneWidget);
    expect(find.text(AppStrings.rememberMe), findsOneWidget);
    expect(find.text(AppStrings.signIn), findsOneWidget);
    expect(find.text(AppStrings.forgotPassword), findsOneWidget);
  });

  testWidgets('renders on a tablet without overflowing', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester, tablet);

    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(find.text(AppStrings.signIn), findsOneWidget);
  });

  testWidgets('shows validation errors instead of calling the server', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester, phone);

    await tester.tap(find.text(AppStrings.signIn));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.emailRequired), findsOneWidget);
    expect(find.text(AppStrings.passwordRequired), findsOneWidget);
  });

  testWidgets('rejects a malformed email', (WidgetTester tester) async {
    await pumpLogin(tester, phone);

    await tester.enterText(find.byType(TextField).first, 'not-an-email');
    await tester.tap(find.text(AppStrings.signIn));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.emailInvalid), findsOneWidget);
  });

  testWidgets('accepts iDempiere emails with spaces around @', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester, phone);

    await tester.enterText(
      find.byType(TextField).first,
      'admin @ gardenworld.com',
    );
    await tester.tap(find.text(AppStrings.signIn));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.emailInvalid), findsNothing);
    expect(find.text(AppStrings.passwordRequired), findsOneWidget);
  });

  testWidgets('toggles password visibility', (WidgetTester tester) async {
    await pumpLogin(tester, phone);

    EditableText passwordField() {
      return tester.widget<EditableText>(
        find.descendant(
          of: find.byType(TextField).at(1),
          matching: find.byType(EditableText),
        ),
      );
    }

    expect(passwordField().obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();

    expect(passwordField().obscureText, isFalse);
  });

  testWidgets('reveals the server field from the advanced section', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester, phone);

    expect(find.text(AppStrings.serverUrl), findsNothing);

    await tester.tap(find.text(AppStrings.advanced));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.serverUrl), findsOneWidget);
  });
}
