import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:idempiere_sales_app/core/app_strings.dart';
import 'package:idempiere_sales_app/features/auth/auth_session.dart';

/// Owns the login request state independently from the login presentation.
class LoginController extends ChangeNotifier {
  LoginController(this._auth);

  final AuthSession _auth;

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? get initialEmail => _auth.rememberedEmail;
  String? get initialServerUrl => _auth.baseUrl;

  Future<LoginAttemptResult> submit({
    required String email,
    required String password,
    required String serverUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.login(
        baseUrl: serverUrl,
        userName: email,
        password: password,
      );
      return const LoginAttemptResult.success();
    } on SocketException {
      return const LoginAttemptResult.failure(AppStrings.networkError);
    } on TimeoutException {
      return const LoginAttemptResult.failure(AppStrings.networkError);
    } catch (_) {
      return const LoginAttemptResult.failure(AppStrings.invalidCredentials);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class LoginAttemptResult {
  const LoginAttemptResult.success() : errorMessage = null;

  const LoginAttemptResult.failure(this.errorMessage);

  final String? errorMessage;

  bool get succeeded => errorMessage == null;
}
