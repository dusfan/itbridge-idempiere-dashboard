import 'package:idempiere_sales_app/utils/rest_json.dart';

class Metric {
  const Metric({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
  });

  final String label;
  final String value;
  final String change;
  final bool isPositive;
}

class BankBalance {
  const BankBalance({required this.bankName, required this.amount});

  final String bankName;
  final double amount;
}

class DailyBankRecord {
  const DailyBankRecord({
    required this.totalBal,
    required this.currentBankBal,
    required this.arNoClearNoReconBal,
    required this.apNoClearNoReconBal,
    this.bankName,
    this.date,
  });

  factory DailyBankRecord.fromJson(Map<String, dynamic> json) {
    return DailyBankRecord(
      totalBal: _readNum(json, 'Total_Bal'),
      currentBankBal: _readNum(json, 'CurrentBank_Bal'),
      arNoClearNoReconBal: _readNum(json, 'AR_NoClear_NoRecon_Bal'),
      apNoClearNoReconBal: _readNum(json, 'AP_NoClear_NoRecon_Bal'),
      bankName: identifierOf(json['C_BankAccount_ID']) ??
          _readString(json, 'BankName') ??
          _readString(json, 'Bank_Name') ??
          _readString(json, 'BankAccountName') ??
          _readString(json, 'AD_Org_Name'),
      date: _readDate(json),
    );
  }

  final double totalBal;
  final double currentBankBal;
  final double arNoClearNoReconBal;
  final double apNoClearNoReconBal;
  final String? bankName;
  final DateTime? date;

  double get pendingBal => totalBal - currentBankBal;

  static double _readNum(Map<String, dynamic> json, String key) {
    final raw = json[key];
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw.trim()) ?? 0.0;
    return 0.0;
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final raw = json[key];
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    return null;
  }

  static DateTime? _readDate(Map<String, dynamic> json) {
    for (final key in const [
      'Created',
      'DateAcct',
      'DateTrx',
      'MovementDate',
      'Date',
    ]) {
      final raw = json[key];
      if (raw is String && raw.isNotEmpty) {
        final parsed = DateTime.tryParse(raw);
        if (parsed != null) {
          return DateTime(parsed.year, parsed.month, parsed.day);
        }
      }
    }
    return null;
  }
}
