import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/stock_detail_entity.dart';
import '../../domain/entities/user_position_entity.dart';

class PositionCard extends StatelessWidget {
  final StockDetailEntity detail;

  const PositionCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final pos = detail.position;
    final marketValue = pos.marketValue(detail.currentPrice);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Position',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // ── Grid: 2 columns ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _PositionStat(
                  label: 'SHARES',
                  value: pos.shares.toString(),
                ),
              ),
              Expanded(
                child: _PositionStat(
                  label: 'MARKET VALUE',
                  value: '₹${_fmt(marketValue)}',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _PositionStat(
                  label: 'AVG. COST',
                  value: '₹${_fmt(pos.avgCost)}',
                ),
              ),
              Expanded(
                child: _PositionStat(
                  label: 'PORTFOLIO DIVERSITY',
                  value: '${pos.portfolioDiversity.toStringAsFixed(2)}%',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          const SizedBox(height: 16),

          // ── Return rows ──────────────────────────────────────
          _ReturnRow(
            label: "Today's Return",
            returnAmt: pos.todayReturn,
            returnPct: pos.todayReturnPercent,
          ),

          const SizedBox(height: 14),

          _ReturnRow(
            label: 'Total Return',
            returnAmt: pos.totalReturn,
            returnPct: pos.totalReturnPercent,
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    // Compact formatting: ₹1,400.4 style (1 decimal for market value)
    final str = v.toStringAsFixed(1);
    final parts = str.split('.');
    final inte = parts[0];
    final dec = parts[1];

    if (inte.length <= 3) return '$inte.$dec';

    final last3 = inte.substring(inte.length - 3);
    final rest = inte.substring(0, inte.length - 3);
    final groups = <String>[];
    for (int i = rest.length; i > 0; i -= 2) {
      groups.insert(0, rest.substring(i < 2 ? 0 : i - 2, i));
    }
    return '${groups.join(',')},${last3}.$dec';
  }
}

// ── Stat cell ────────────────────────────────────────────────────────────────

class _PositionStat extends StatelessWidget {
  final String label;
  final String value;

  const _PositionStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// ── Return row ───────────────────────────────────────────────────────────────

class _ReturnRow extends StatelessWidget {
  final String label;
  final double returnAmt;
  final double returnPct;

  const _ReturnRow({
    required this.label,
    required this.returnAmt,
    required this.returnPct,
  });

  @override
  Widget build(BuildContext context) {
    final isGain = returnAmt >= 0;
    final color = isGain ? AppColors.gain : AppColors.loss;
    final sign = isGain ? '+' : '';
    final amtStr = '$sign₹${returnAmt.abs().toStringAsFixed(1)}';
    final pctStr = '(${sign}${returnPct.toStringAsFixed(2)}%)';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        Row(
          children: [
            Text(
              amtStr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              pctStr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
