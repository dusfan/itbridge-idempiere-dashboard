import 'package:flutter/material.dart';

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

class PaymentSummary {
  const PaymentSummary({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final String amount;
  final Color color;
}

class Flight {
  const Flight({
    required this.code,
    required this.route,
    required this.rate,
  });

  final String code;
  final String route;
  final String rate;
}
