import 'package:idempiere_rest/idempiere_rest.dart';
import 'package:idempiere_sales_app/features/dashboard/core/theme/app_theme.dart';
import 'package:idempiere_sales_app/features/dashboard/domain/dashboard_models.dart';

/// Replace this class with an API-backed repository without changing widgets.
abstract class DashboardRepository {
  List<Metric> get metrics;
  List<double> get sales;
  List<PaymentSummary> get payments;
  List<Flight> get topFlights;
  Future<int> get ticketsTodayCount;
}

class MockDashboardRepository implements DashboardRepository {
  const MockDashboardRepository();

  @override
  List<Metric> get metrics => const [
        Metric(
            label: 'Solde réel',
            value: '125 000 €',
            change: '3.2%',
            isPositive: true),
        Metric(
            label: 'Solde courant',
            value: '145 000 €',
            change: '1.8%',
            isPositive: true),
        Metric(
            label: 'Billets aujourd’hui',
            value: '248',
            change: '12%',
            isPositive: true),
        Metric(
            label: 'Chiffre d’affaires',
            value: '52 000 €',
            change: '8.5%',
            isPositive: true),
        Metric(
            label: 'Factures impayées',
            value: '34',
            change: '4',
            isPositive: false),
        Metric(
            label: 'Montant impayé',
            value: '19 000 €',
            change: '7.2%',
            isPositive: false),
        Metric(
            label: 'Vols aujourd’hui',
            value: '15',
            change: '2',
            isPositive: true),
        Metric(
            label: 'Pèlerins', value: '1 654', change: '120', isPositive: true),
      ];

  @override
  List<double> get sales => const [
        14,
        22,
        18,
        31,
        43,
        28,
        33,
        37,
        30,
        36,
        47,
        43,
        52,
        47,
        56,
        65,
        41,
        32,
        36,
        25,
        30,
        49,
        43,
        39,
        33,
        40,
        28,
        46,
        43,
        57,
        51,
        63,
        56,
        61,
        54,
        66,
        79,
        62,
        53,
        58,
        45,
        49,
        47,
        54,
        61,
      ];

  @override
  List<PaymentSummary> get payments => const [
        PaymentSummary(
            label: 'Payé', amount: '37 440 €', color: AppColors.green),
        PaymentSummary(
            label: 'Non payé', amount: '14 560 €', color: AppColors.red),
      ];

  @override
  List<Flight> get topFlights => const [
        Flight(code: 'AH201', route: 'Alger → Djeddah', rate: '86%'),
        Flight(code: 'SV102', route: 'Alger → Médine', rate: '79%'),
        Flight(code: 'TU561', route: 'Tunis → Djeddah', rate: '74%'),
        Flight(code: 'EK740', route: 'Alger → Dubaï', rate: '68%'),
        Flight(code: 'QR139', route: 'Alger → Doha', rate: '64%'),
      ];

  @override
  Future<int> get ticketsTodayCount => Future.value(248);
}

/// Loads the live ticket count from the flight-details view configured in the
/// dashboard Postman collection.
class IdempiereDashboardRepository extends MockDashboardRepository {
  const IdempiereDashboardRepository();

  static const _pageSize = 100;

  @override
  Future<int> get ticketsTodayCount async {
    final filter = FilterBuilder()
      ..addFilter(
        'DepartDateTime_Direct',
        Operators.ge,
        const _CurrentDateFilterValue(),
      );

    var count = 0;
    for (var skip = 0;; skip += _pageSize) {
      final details = await IdempiereClient().get<_FlightDetail>(
        '/models/rv_vol_details_rest',
        _FlightDetail.new,
        filter: filter,
        top: _pageSize,
        skip: skip,
      );
      count += details.length;

      if (details.length < _pageSize) return count;
    }
  }
}

/// Produces the server-side `current_date` expression without quoting it.
class _CurrentDateFilterValue {
  const _CurrentDateFilterValue();

  @override
  String toString() => 'current_date';
}

/// The KPI only needs a record for counting, but the REST client requires a
/// model type to deserialize each row returned by the view.
class _FlightDetail extends ModelBase {
  _FlightDetail(Map<String, dynamic> json) : super(json);

  @override
  _FlightDetail fromJson(Map<String, dynamic> json) => _FlightDetail(json);

  @override
  Map<String, dynamic> toJson() => const {};
}
