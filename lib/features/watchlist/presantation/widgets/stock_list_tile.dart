import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/stock_entity.dart';
import 'exchange_badge.dart';
import 'stock_logo_avatar.dart';

class StockListTile extends StatelessWidget {
  final StockEntity stock;
  final VoidCallback onTap;

  const StockListTile({super.key, required this.stock, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isGain = stock.isGain;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.white,
              Colors.white,
              isGain ? AppColors.gainBg : AppColors.lossBg,
            ],
            stops: const [
              0.0, // start
              0.65, // 75% white
              1.0, // end color
            ],
          ),
        ),
        child: Row(
          children: [
            // ── Logo ──────────────────────────────────────────
            StockLogoAvatar(symbol: stock.symbol, hexColor: stock.logoAsset),
            const SizedBox(width: 12),

            // ── Symbol + Full Name ─────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        stock.symbol,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      ExchangeBadge(exchange: stock.exchange),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stock.fullName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Price + Change ─────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: _PriceText(price: stock.currentPrice),
                ),
                const SizedBox(height: 3),
                _ChangeText(changePercent: stock.changePercent, isGain: isGain),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets — isolated for AnimatedSwitcher granularity ──────────────────

class _PriceText extends StatelessWidget {
  final double price;
  const _PriceText({required this.price});

  @override
  Widget build(BuildContext context) {
    // Format: ₹2,061.70
    final formatted = _formatINR(price);
    return Text(
      formatted,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }

  String _formatINR(double price) {
    // Manual INR formatting to avoid intl dependency in widget
    final parts = price.toStringAsFixed(2).split('.');
    final integer = parts[0];
    final decimal = parts[1];
    final buffer = StringBuffer('₹');

    // Indian numbering: last 3 digits, then groups of 2
    if (integer.length <= 3) {
      buffer.write(integer);
    } else {
      final last3 = integer.substring(integer.length - 3);
      final rest = integer.substring(0, integer.length - 3);
      final groups = <String>[];
      for (int i = rest.length; i > 0; i -= 2) {
        groups.insert(0, rest.substring(i < 2 ? 0 : i - 2, i));
      }
      buffer.write('${groups.join(',')},');
      buffer.write(last3);
    }

    buffer.write('.$decimal');
    return buffer.toString();
  }
}

class _ChangeText extends StatelessWidget {
  final double changePercent;
  final bool isGain;

  const _ChangeText({required this.changePercent, required this.isGain});

  @override
  Widget build(BuildContext context) {
    final sign = isGain ? '+' : '';
    final label = '$sign${changePercent.toStringAsFixed(2)}%';

    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: isGain ? AppColors.gain : AppColors.loss,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
