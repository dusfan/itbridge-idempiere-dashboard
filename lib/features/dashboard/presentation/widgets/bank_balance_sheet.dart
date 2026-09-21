import 'package:flutter/material.dart';

import 'package:idempiere_sales_app/features/dashboard/core/theme/app_theme.dart';
import 'package:idempiere_sales_app/features/dashboard/domain/dashboard_models.dart';

/// Bottom sheet showing the per-bank balance breakdown (Solde par banque).
class BankBalanceSheet extends StatelessWidget {
  const BankBalanceSheet({required this.balances, super.key});

  final List<BankBalance> balances;

  @override
  Widget build(BuildContext context) {
    final total = balances.fold<double>(0.0, (sum, b) => sum + b.amount);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_rounded,
                    color: AppColors.blue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Solde par banque',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded,
                      size: 20, color: AppColors.mutedInk),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (balances.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Aucune donnée',
                      style:
                          TextStyle(color: AppColors.mutedInk, fontSize: 12)),
                ),
              )
            else
              for (final balance in balances)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                            color: AppColors.blue, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          balance.bankName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatAmount(balance.amount),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            if (balances.isNotEmpty) ...[
              const Divider(height: 1, color: AppColors.line),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Text(
                    _formatAmount(total),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
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