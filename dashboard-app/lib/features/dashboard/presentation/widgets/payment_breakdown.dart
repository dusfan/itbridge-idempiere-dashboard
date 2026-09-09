import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/dashboard_models.dart';
import 'dashboard_card.dart';

class PaymentBreakdown extends StatelessWidget {
  const PaymentBreakdown({required this.payments, super.key});

  final List<PaymentSummary> payments;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition des paiements',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.ink),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 94,
                height: 94,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: .72,
                      strokeWidth: 10,
                      color: AppColors.green,
                      backgroundColor: AppColors.red,
                    ),
                    Center(
                      child: Text('72%',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final payment in payments) ...[
                      _PaymentLegend(payment: payment),
                      if (payment != payments.last) const SizedBox(height: 15),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _PaymentLegend extends StatelessWidget {
  const _PaymentLegend({required this.payment});

  final PaymentSummary payment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 9,
            height: 9,
            decoration:
                BoxDecoration(color: payment.color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(payment.label,
                style:
                    const TextStyle(fontSize: 10, color: AppColors.mutedInk)),
            const SizedBox(height: 2),
            Text(payment.amount,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink)),
          ],
        ),
      ],
    );
  }
}
