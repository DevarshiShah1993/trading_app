import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/stock_detail_entity.dart';

class TimeRangeSelector extends StatelessWidget {
  final ChartRange selected;
  final ValueChanged<ChartRange> onChanged;

  const TimeRangeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _items = [
    (range: ChartRange.oneDay, label: '1D'),
    (range: ChartRange.oneWeek, label: '1W'),
    (range: ChartRange.oneMonth, label: '1M'),
    (range: ChartRange.threeMonth, label: '3M'),
    (range: ChartRange.sixMonth, label: '6M'),
    (range: ChartRange.ytd, label: 'YTD'),
    (range: ChartRange.oneYear, label: '1Y'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          final isActive = item.range == selected;

          return GestureDetector(
            onTap: () => onChanged(item.range),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
