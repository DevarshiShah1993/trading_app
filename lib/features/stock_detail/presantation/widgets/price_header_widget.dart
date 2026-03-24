import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/stock_detail_entity.dart';

class PriceHeaderWidget extends StatelessWidget {
  final StockDetailEntity detail;

  const PriceHeaderWidget({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final isGain = detail.absoluteGain >= 0;
    final gainColor = isGain ? AppColors.gain : AppColors.loss;
    final sign = isGain ? '+' : '';
    final priceStr = _splitPrice(detail.currentPrice);
    final absGainStr = '$sign₹${detail.absoluteGain.abs().toStringAsFixed(0)}';
    final pctGainStr = '(${detail.absoluteGainPercent.toStringAsFixed(1)}%)';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Large price ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '₹',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Text(
                  key: ValueKey(priceStr.integer),
                  priceStr.integer,
                  style: const TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.0,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Text(
                '.${priceStr.decimal}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ── Gain row ─────────────────────────────────────────
          Row(
            children: [
              Text(
                '$absGainStr  $pctGainStr',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: gainColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Tags row ─────────────────────────────────────────
          Row(
            children: detail.tags.map((tag) => _TagChip(label: tag)).toList(),
          ),
        ],
      ),
    );
  }

  _PriceParts _splitPrice(double price) {
    final str = price.toStringAsFixed(2);
    final parts = str.split('.');
    return _PriceParts(integer: _formatINRInteger(parts[0]), decimal: parts[1]);
  }

  String _formatINRInteger(String integer) {
    if (integer.length <= 3) return integer;
    final last3 = integer.substring(integer.length - 3);
    final rest = integer.substring(0, integer.length - 3);
    final groups = <String>[];
    for (int i = rest.length; i > 0; i -= 2) {
      groups.insert(0, rest.substring(i < 2 ? 0 : i - 2, i));
    }
    return '${groups.join(',')},${last3}';
  }
}

class _PriceParts {
  final String integer;
  final String decimal;
  const _PriceParts({required this.integer, required this.decimal});
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
