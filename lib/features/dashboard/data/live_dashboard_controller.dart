import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:idempiere_sales_app/features/auth/auth_session.dart';
import 'package:idempiere_sales_app/features/dashboard/domain/dashboard_models.dart';

/// Loads the dashboard KPIs straight from the live iDempiere API.
///
/// The only source of truth is the day-bank report view:
///   GET /api/v1/models/Chuboe_RV_Daily_Bank?$filter=c_currency_id eq 235
/// No mocked files are opened or used as a fallback for these figures.
class DashboardController extends ChangeNotifier {
  DashboardController(this._auth);

  final AuthSession _auth;

  static const _filter = 'c_currency_id eq 235';

  bool _loading = false;
  String? _error;
  final List<BankBalance> _bankBalances = [];
  List<double> _chartValues = [];
  Metric? _soldeReel;
  Metric? _soldeTotal;
  Metric? _soldeEnCours;

  bool get loading => _loading;
  String? get error => _error;
  List<BankBalance> get bankBalances => List.unmodifiable(_bankBalances);
  List<double> get chartValues => List.unmodifiable(_chartValues);
  Metric? get soldeReel => _soldeReel;
  Metric? get soldeTotal => _soldeTotal;
  Metric? get soldeEnCours => _soldeEnCours;

  Future<void> load() async {
    final baseUrl = _auth.baseUrl;
    final token = _auth.session?.token;

    if (baseUrl == null || token == null) {
      _loading = false;
      _error = 'No authenticated session available.';
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    final root = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$root/models/Chuboe_RV_Daily_Bank').replace(
      queryParameters: {'\$filter': _filter},
    );

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers
        ..set(HttpHeaders.acceptHeader, 'application/json')
        ..set(HttpHeaders.contentTypeHeader, 'application/json')
        ..set(HttpHeaders.authorizationHeader, 'Bearer $token');

      final response = await request.close();
      final rawBody = await response.transform(utf8.decoder).join();

      if (response.statusCode != HttpStatus.ok) {
        _error = 'Dashboard API returned HTTP ${response.statusCode}.';
        return;
      }

      final json = jsonDecode(rawBody) as Map<String, dynamic>;
      final records = (json['records'] as List<dynamic>? ?? const [])
          .map((record) =>
              DailyBankRecord.fromJson(record as Map<String, dynamic>))
          .toList();

      var totalBalSum = 0.0;
      var currentBankBalSum = 0.0;
      var pendingSum = 0.0;
      final byBank = <String, double>{};
      final byDate = <DateTime, double>{};

      for (final record in records) {
        totalBalSum += record.totalBal;
        currentBankBalSum += record.currentBankBal;
        pendingSum += record.pendingBal;

        final bank = record.bankName ?? 'Banque ${byBank.length + 1}';
        byBank[bank] = (byBank[bank] ?? 0) + record.totalBal;

        final date = record.date;
        if (date != null) byDate[date] = (byDate[date] ?? 0) + record.totalBal;
      }

      _bankBalances
        ..clear()
        ..addAll(
          byBank.entries.map(
              (e) => BankBalance(bankName: e.key, amount: e.value)),
        );

      final dates = byDate.keys.toList()..sort();
      _chartValues = dates.map((date) => byDate[date]!).toList();

      _soldeReel = Metric(
        label: 'Solde réel',
        value: _formatAmount(currentBankBalSum),
        change: '',
        isPositive: currentBankBalSum >= 0,
      );
      _soldeTotal = Metric(
        label: 'Solde total',
        value: _formatAmount(totalBalSum),
        change: '',
        isPositive: totalBalSum >= 0,
      );
      _soldeEnCours = Metric(
        label: 'Solde en cours',
        value: _formatAmount(pendingSum),
        change: '',
        isPositive: pendingSum >= 0,
      );
    } on SocketException catch (e) {
      debugPrint('=== DASHBOARD NETWORK ERROR ===\n$e');
      _error = 'Network error while loading the dashboard.';
    } on TimeoutException catch (e) {
      debugPrint('=== DASHBOARD TIMEOUT ===\n$e');
      _error = 'The dashboard request timed out.';
    } catch (e) {
      debugPrint('=== DASHBOARD PARSE/UNEXPECTED ERROR ===\n$e');
      _error = 'Could not load dashboard data.';
    } finally {
      client.close();
      _loading = false;
      notifyListeners();
    }
  }

  String _formatAmount(double value) {
    final sign = value < 0 ? '-' : '';
    final abs = value.abs();
    final digits = abs.toStringAsFixed(2).split('.');
    final intPart = digits[0];
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    return '$sign$buffer.${digits[1]} DZD';
  }
}