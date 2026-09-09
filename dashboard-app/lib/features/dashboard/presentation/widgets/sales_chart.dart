import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'dashboard_card.dart';

class SalesChart extends StatelessWidget {
  const SalesChart({required this.values, super.key});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Évolution des ventes (30 derniers jours)',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.ink),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                const SizedBox(
                  width: 30,
                  child: _YAxisLabels(),
                ),
                Expanded(
                  child: CustomPaint(
                    painter: _SalesChartPainter(values),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 31, top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('01 Jun', style: _axisText),
                Text('08 Jun', style: _axisText),
                Text('15 Jun', style: _axisText),
                Text('22 Jun', style: _axisText),
                Text('29 Jun', style: _axisText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _axisText = TextStyle(fontSize: 8, color: AppColors.mutedInk);

class _YAxisLabels extends StatelessWidget {
  const _YAxisLabels();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('80K', style: _axisText),
        Text('60K', style: _axisText),
        Text('40K', style: _axisText),
        Text('20K', style: _axisText),
        Text('0', style: _axisText),
      ],
    );
  }
}

class _SalesChartPainter extends CustomPainter {
  _SalesChartPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    const topPadding = 3.0;
    const bottomPadding = 1.0;
    final chartHeight = size.height - topPadding - bottomPadding;
    final gridPaint = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1;

    for (var i = 0; i < 5; i++) {
      final y = topPadding + chartHeight * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.isEmpty) return;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue) == 0 ? 1.0 : maxValue - minValue;
    final step = values.length == 1 ? 0.0 : size.width / (values.length - 1);

    Offset pointAt(int index, double value) {
      final normalized = (value - minValue) / range;
      return Offset(index * step, topPadding + (1 - normalized) * chartHeight);
    }

    final line = Path()
      ..moveTo(pointAt(0, values.first).dx, pointAt(0, values.first).dy);
    for (var i = 1; i < values.length; i++) {
      final point = pointAt(i, values[i]);
      line.lineTo(point.dx, point.dy);
    }

    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final shader = ui.Gradient.linear(
      const Offset(0, topPadding),
      Offset(0, size.height),
      const [Color(0x291465DF), Color(0x001465DF)],
    );
    canvas.drawPath(fill, Paint()..shader = shader);
    canvas.drawPath(
      line,
      Paint()
        ..color = const Color(0xFF477DA9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.1
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) =>
      oldDelegate.values != values;
}
