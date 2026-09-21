import 'package:flutter/material.dart';

import 'package:idempiere_sales_app/features/dashboard/core/theme/app_theme.dart';
import 'package:idempiere_sales_app/features/dashboard/data/live_dashboard_controller.dart';
import 'package:idempiere_sales_app/features/dashboard/domain/dashboard_models.dart';
import 'package:idempiere_sales_app/features/dashboard/presentation/widgets/bank_balance_sheet.dart';
import 'package:idempiere_sales_app/features/dashboard/presentation/widgets/dashboard_sidebar.dart';
import 'package:idempiere_sales_app/features/dashboard/presentation/widgets/metric_card.dart';
import 'package:idempiere_sales_app/features/dashboard/presentation/widgets/sales_chart.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    this.onLogout,
    this.onOpenOrders,
  });

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
              const Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 19, 24, 24),
                  child: _DashboardContent(desktop: true),
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
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: _DashboardContent(desktop: false),
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
  const _DashboardContent({required this.desktop});

  final bool desktop;

  void _showBankBreakdown(BuildContext context, DashboardController controller) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => BankBalanceSheet(balances: controller.bankBalances),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (context, controller, _) {
        final kpis = <Metric>[
          controller.soldeReel ??
              const Metric(
                  label: 'Solde réel',
                  value: '···',
                  change: '',
                  isPositive: true),
          controller.soldeTotal ??
              const Metric(
                  label: 'Solde total',
                  value: '···',
                  change: '',
                  isPositive: true),
          controller.soldeEnCours ??
              const Metric(
                  label: 'Solde en cours',
                  value: '···',
                  change: '',
                  isPositive: true),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tableau de bord',
                style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: desktop ? 23 : 28),
            _KpiGrid(
              kpis: kpis,
              desktop: desktop,
              onBreakdownTap: () =>
                  _showBankBreakdown(context, controller),
            ),
            SizedBox(height: desktop ? 16 : 22),
            SizedBox(
              height: desktop ? 260 : 250,
              child: SalesChart(values: controller.chartValues),
            ),
            if (controller.error != null) ...[
              const SizedBox(height: 12),
              Text(controller.error!,
                  style: const TextStyle(color: AppColors.red)),
            ],
          ],
        );
      },
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({
    required this.kpis,
    required this.desktop,
    required this.onBreakdownTap,
  });

  final List<Metric> kpis;
  final bool desktop;
  final VoidCallback onBreakdownTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: kpis.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: desktop ? 3 : 1,
        mainAxisSpacing: desktop ? 12 : 13,
        crossAxisSpacing: desktop ? 12 : 13,
        mainAxisExtent: desktop ? 104 : 129,
      ),
      itemBuilder: (context, index) => GestureDetector(
        onTap: onBreakdownTap,
        child: MetricCard(metric: kpis[index]),
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