import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'session/auth_session.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

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
