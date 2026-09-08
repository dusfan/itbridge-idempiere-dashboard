import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idempiere_sales_app/core/theme.dart';
import 'package:idempiere_sales_app/features/auth/auth_session.dart';
import 'package:idempiere_sales_app/features/login/login_screen.dart';
import 'package:provider/provider.dart';

/// Renders the login screen to PNG so the layout can be reviewed without
/// launching a device. Regenerate with:
///
///   flutter test --update-goldens test/login_golden_test.dart
Future<void> pumpAt(
  WidgetTester tester,
  Size size, {
  FakeViewPadding padding = FakeViewPadding.zero,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.view.padding = padding;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ChangeNotifierProvider<AuthSession>(
      create: (_) => AuthSession(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const LoginScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('golden: login on a phone', (WidgetTester tester) async {
    // Notch and home-indicator insets, as on an iPhone X-class device.
    await pumpAt(
      tester,
      const Size(375, 812),
      padding: const FakeViewPadding(top: 44, bottom: 34),
    );
    await expectLater(
      find.byType(LoginScreen),
      matchesGoldenFile('goldens/login_phone.png'),
    );
  });

  testWidgets('golden: login on a tablet', (WidgetTester tester) async {
    await pumpAt(tester, const Size(834, 1112));
    await expectLater(
      find.byType(LoginScreen),
      matchesGoldenFile('goldens/login_tablet.png'),
    );
  });
}
