import 'package:flutter/foundation.dart';
import 'package:idempiere_rest/idempiere_rest.dart';
// ignore: implementation_imports
import 'package:idempiere_rest/src/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSession extends ChangeNotifier {
  static const _prefBaseUrl = 'idempiere_base_url';
  static const _prefEmail = 'idempiere_email';

  String? baseUrl;
  String? rememberedEmail;
  Session? session;
  LoginResponse? loginResponse;

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

  Future<void> login({
    required String baseUrl,
    required String userName,
    required String password,
  }) async {
    this.baseUrl = baseUrl;
    IdempiereClient().setBaseUrl(baseUrl);
    loginResponse = await IdempiereClient().login('/auth/tokens', userName, password);
    notifyListeners();
  }

  Future<List<Role>> getRoles(int clientId) => IdempiereClient().getRoles(clientId);

  Future<List<Organization>> getOrganizations(int clientId, int roleId) =>
      IdempiereClient().getOrganizations(clientId, roleId);

  Future<List<Warehouse>> getWarehouses(int clientId, int roleId, int orgId) =>
      IdempiereClient().getWarehouses(clientId, roleId, orgId);

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
    loginResponse = null;
    notifyListeners();
  }
}