import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/dashboard_models.dart';
import 'dashboard_card.dart';

class TopFlights extends StatelessWidget {
  const TopFlights({required this.flights, super.key});

  final List<Flight> flights;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.add_rounded, color: AppColors.blue, size: 17),
              SizedBox(width: 6),
              Text('Top 5 vols',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink)),
            ],
          ),
          const SizedBox(height: 12),
          for (final flight in flights)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.flight_rounded,
                      size: 13, color: AppColors.ink),
                  const SizedBox(width: 7),
                  Text(flight.code,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      flight.route,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.mutedInk),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(flight.rate,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
