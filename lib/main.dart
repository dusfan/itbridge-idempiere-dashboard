import 'package:flutter/material.dart';
import 'package:idempiere_sales_app/core/theme.dart';
import 'package:idempiere_sales_app/features/auth/auth_session.dart';
import 'package:idempiere_sales_app/features/auth/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const SalesOrderApp());
}

class SalesOrderApp extends StatelessWidget {
  const SalesOrderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthSession(),
      child: MaterialApp(
        title: 'iDempiere Sales',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}
