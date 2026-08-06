import 'package:flutter/foundation.dart';
import 'package:idempiere_rest/idempiere_rest.dart';
// ignore: implementation_imports
import 'package:idempiere_rest/src/session.dart'; // not re-exported by the package's public barrel
import 'package:shared_preferences/shared_preferences.dart';

/// Thin app-level wrapper around the [IdempiereClient] singleton.
///
/// The client already keeps the bearer token internally once logged in; this
/// class exists so widgets can *watch* login state (via [ChangeNotifier]) and
/// so screens building new records can read the logged-in org/warehouse.
class AuthSession extends ChangeNotifier {
  static const _prefBaseUrl = 'idempiere_base_url';
  static const _prefEmail = 'idempiere_email';

  String? baseUrl;
  String? rememberedEmail;
  Session? session;

  bool get isLoggedIn => session != null;

  Future<void> loadRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString(_prefBaseUrl);
    rememberedEmail = prefs.getString(_prefEmail);
    notifyListeners();
  }

  Future<void> rememberLogin({required String baseUrl, required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefBaseUrl, baseUrl);
    await prefs.setString(_prefEmail, email);
  }

  Future<void> oneStepLogin({
    required String baseUrl,
    required String userName,
    required String password,
    required int clientId,
    required int roleId,
    int? organizationId,
    int? warehouseId,
    String? language,
  }) async {
    this.baseUrl = baseUrl;
    IdempiereClient().setBaseUrl(baseUrl);
    session = await IdempiereClient().oneStepLogin(
      '/auth/tokens',
      userName,
      password,
      clientId,
      roleId,
      organizationId: organizationId,
      warehouseId: warehouseId,
      language: language,
    );
    notifyListeners();
  }

  void logout() {
    session = null;
    notifyListeners();
  }
}
