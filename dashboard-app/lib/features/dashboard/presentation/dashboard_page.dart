import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/mock_dashboard_repository.dart';
import '../domain/dashboard_models.dart';
import 'widgets/dashboard_sidebar.dart';
import 'widgets/metric_card.dart';
import 'widgets/payment_breakdown.dart';
import 'widgets/sales_chart.dart';
import 'widgets/top_flights.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    this.repository = const MockDashboardRepository(),
    this.onLogout,
    this.onOpenOrders,
  });

  final DashboardRepository repository;
  final VoidCallback? onLogout;
  final VoidCallback? onOpenOrders;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _activeMobileTab = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useDesktopLayout = constraints.maxWidth >= 720;
        return useDesktopLayout ? _buildDesktop() : _buildMobile();
      },
    );
  }

  Widget _buildDesktop() {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(16),
            color: AppColors.canvas,
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              DashboardSidebar(
                onLogout: widget.onLogout,
                onOpenOrders: widget.onOpenOrders,
              ),
              const VerticalDivider(
                width: 1,
                thickness: 1,
                color: AppColors.line,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 19, 24, 24),
                  child: _DashboardContent(
                      repository: widget.repository, desktop: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobile() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child:
              _DashboardContent(repository: widget.repository, desktop: false),
        ),
      ),
      bottomNavigationBar: _MobileNavigation(
        currentIndex: _activeMobileTab,
        onChanged: (index) {
          if (index == 1 && widget.onOpenOrders != null) {
            widget.onOpenOrders!();
            return;
          }
          setState(() => _activeMobileTab = index);
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.repository, required this.desktop});

  final DashboardRepository repository;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final metrics = repository.metrics;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tableau de bord',
            style: Theme.of(context).textTheme.headlineMedium),
        SizedBox(height: desktop ? 23 : 28),
        _MetricGrid(metrics: metrics, desktop: desktop),
        SizedBox(height: desktop ? 16 : 22),
        if (desktop)
          _DesktopInsights(repository: repository)
        else
          SizedBox(
            height: 250,
            child: SalesChart(values: repository.sales),
          ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics, required this.desktop});

  final List<Metric> metrics;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: metrics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: desktop ? 4 : 2,
        mainAxisSpacing: desktop ? 12 : 13,
        crossAxisSpacing: desktop ? 12 : 13,
        mainAxisExtent: desktop ? 104 : 129,
      ),
      itemBuilder: (context, index) => MetricCard(metric: metrics[index]),
    );
  }
}

class _DesktopInsights extends StatelessWidget {
  const _DesktopInsights({required this.repository});

  final DashboardRepository repository;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 14, child: SalesChart(values: repository.sales)),
          const SizedBox(width: 14),
          Expanded(
              flex: 10, child: PaymentBreakdown(payments: repository.payments)),
          const SizedBox(width: 14),
          Expanded(flex: 10, child: TopFlights(flights: repository.topFlights)),
        ],
      ),
    );
  }
}

class _MobileNavigation extends StatelessWidget {
  const _MobileNavigation(
      {required this.currentIndex, required this.onChanged});

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const _items = [
    _MobileNavItem('Dashboard', Icons.home_rounded),
    _MobileNavItem('Commandes', Icons.receipt_long_outlined),
    _MobileNavItem('Vols', Icons.flight_rounded),
    _MobileNavItem('Factures', Icons.receipt_long_outlined),
    _MobileNavItem('Plus', Icons.more_horiz_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          for (var index = 0; index < _items.length; index++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(index),
                child: _MobileNavButton(
                    item: _items[index], selected: currentIndex == index),
              ),
            ),
        ],
      ),
    );
  }
}

class _MobileNavItem {
  const _MobileNavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _MobileNavButton extends StatelessWidget {
  const _MobileNavButton({required this.item, required this.selected});

  final _MobileNavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.blue : AppColors.mutedInk;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Icon(item.icon, color: color, size: 24),
          const SizedBox(height: 3),
          Text(
            item.label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: color),
          ),
        ],
      ),
    );
  }
}
