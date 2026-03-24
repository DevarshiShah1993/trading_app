import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/chart_point_entity.dart';
import '../../domain/entities/stock_detail_entity.dart';

class StockChartWidget extends StatelessWidget {
  final List<ChartPointEntity> points;
  final ChartRange range;
  final bool isGain;

  const StockChartWidget({
    super.key,
    required this.points,
    required this.range,
    required this.isGain,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const _ChartPlaceholder();

    final spots = _buildSpots();
    final minY = _minY(spots);
    final maxY = _maxY(spots);
    final color = isGain ? AppColors.gain : AppColors.loss;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 16, 0),
      child: SizedBox(
        height: 160,
        child: LineChart(
          duration: const Duration(milliseconds: 200),
          LineChartData(
            // ── Grid ──────────────────────────────────────────
            gridData: const FlGridData(show: false),

            // ── Border ────────────────────────────────────────
            borderData: FlBorderData(show: false),

            // ── Axis titles ───────────────────────────────────
            titlesData: const FlTitlesData(show: false),

            // ── Touch behavior ────────────────────────────────
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => AppColors.textPrimary,
                getTooltipItems: (spots) => spots.map((s) {
                  return LineTooltipItem(
                    '₹${s.y.toStringAsFixed(2)}',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              getTouchedSpotIndicator: (data, indices) => indices.map((i) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: color.withOpacity(0.4),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                  FlDotData(
                    getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                      radius: 4,
                      color: color,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),

            // ── Y axis range with padding ─────────────────────
            minY: minY - (maxY - minY) * 0.1,
            maxY: maxY + (maxY - minY) * 0.1,

            // ── Line data ─────────────────────────────────────
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.3,
                color: color,
                barWidth: 1.8,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color.withOpacity(0.20), color.withOpacity(0.00)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FlSpot> _buildSpots() {
    return points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.price);
    }).toList();
  }

  double _minY(List<FlSpot> spots) =>
      spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);

  double _maxY(List<FlSpot> spots) =>
      spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 160,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
