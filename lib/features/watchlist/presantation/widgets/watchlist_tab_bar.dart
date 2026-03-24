import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class WatchlistTabBar extends StatefulWidget {
  const WatchlistTabBar({super.key});

  @override
  State<WatchlistTabBar> createState() => _WatchlistTabBarState();
}

class _WatchlistTabBarState extends State<WatchlistTabBar> {
  int _selected = 1; // "List 2" active by default (matches screenshot)

  static const _tabs = ['List 1', 'List 2'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final isActive = i == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 14,
                    ),
                    margin: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isActive
                              ? AppColors.textPrimary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      _tabs[i],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // ── Filter + Sort icons ───────────────────────────────
          _IconButton(icon: Icons.filter_list_rounded, onTap: () {}),
          const SizedBox(width: 12),
          _IconButton(icon: Icons.tune_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 22, color: AppColors.textSecondary),
    );
  }
}
