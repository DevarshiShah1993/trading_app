import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class WatchlistSearchBar extends StatelessWidget {
  const WatchlistSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: const Row(
        children: [
           SizedBox(width: 12),
           Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
           SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration:  InputDecoration(
                hintText: 'search for a ticker',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style:  TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
