import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ExchangeBadge extends StatelessWidget {
  final String exchange;

  const ExchangeBadge({super.key, required this.exchange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.badgeBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        exchange,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
