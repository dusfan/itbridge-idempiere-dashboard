import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/dashboard_models.dart';
import 'dashboard_card.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({required this.metric, super.key});

  final Metric metric;

  @override
  Widget build(BuildContext context) {
    final deltaColor = metric.isPositive ? AppColors.green : AppColors.red;
    final deltaSurface =
        metric.isPositive ? AppColors.greenSoft : AppColors.redSoft;
    final deltaIcon = metric.isPositive
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(metric.label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              height: 1,
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.25,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                decoration: BoxDecoration(
                  color: deltaSurface,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(deltaIcon, size: 10, color: deltaColor),
                    const SizedBox(width: 2),
                    Text(
                      metric.change,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: deltaColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              const Text('vs hier',
                  style: TextStyle(fontSize: 10, color: AppColors.mutedInk)),
            ],
          ),
        ],
      ),
    );
  }
}
