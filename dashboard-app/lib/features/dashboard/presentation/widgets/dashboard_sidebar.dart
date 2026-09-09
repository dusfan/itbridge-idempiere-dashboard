import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    super.key,
    this.onLogout,
    this.onOpenOrders,
  });

  final VoidCallback? onLogout;
  final VoidCallback? onOpenOrders;

  @override
  Widget build(BuildContext context) {
    const topItems = [
      _MenuItem('Dashboard', Icons.home_outlined, true),
      _MenuItem('Commandes', Icons.receipt_long_outlined, false),
      _MenuItem('Finance', Icons.account_balance_wallet_outlined, false),
      _MenuItem('Vols', Icons.flight_outlined, false),
      _MenuItem('Billets', Icons.confirmation_number_outlined, false),
      _MenuItem('Pèlerins', Icons.groups_outlined, false),
      _MenuItem('Factures', Icons.receipt_long_outlined, false),
      _MenuItem('Statistiques', Icons.bar_chart_outlined, false),
      _MenuItem('Notifications', Icons.notifications_none_outlined, false,
          badge: true),
      _MenuItem('Profil', Icons.person_outline_rounded, false),
      _MenuItem('Paramètres', Icons.settings_outlined, false),
    ];

    return Container(
      width: 144,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(12, 17, 12, 16),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 6, bottom: 17),
              child: Icon(Icons.menu_rounded, color: AppColors.ink, size: 21),
            ),
          ),
          for (final item in topItems)
            _SidebarItem(
              item: item,
              onTap: item.label == 'Commandes' ? onOpenOrders : null,
            ),
          const Spacer(),
          _SidebarItem(
            item: const _MenuItem('Déconnexion', Icons.logout_outlined, false),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.label, this.icon, this.isSelected, {this.badge = false});

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool badge;
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.item, this.onTap});

  final _MenuItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = item.isSelected ? Colors.white : AppColors.mutedInk;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 29,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: item.isSelected ? AppColors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 14, color: foreground),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: foreground),
                ),
              ),
              if (item.badge)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                      color: AppColors.red, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
