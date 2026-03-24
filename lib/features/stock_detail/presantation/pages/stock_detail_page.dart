import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/stock_detail_entity.dart';
import '../bloc/stock_detail_bloc.dart';
import '../bloc/stock_detail_event.dart';
import '../bloc/stock_detail_state.dart';
import '../widgets/chart_widget.dart';
import '../widgets/position_card.dart';
import '../widgets/price_header_widget.dart';
import '../widgets/time_range_selector.dart';

class StockDetailPage extends StatelessWidget {
  final String symbol;
  final String fullName;

  const StockDetailPage({
    super.key,
    required this.symbol,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StockDetailBloc>()..add(StockDetailStarted(symbol)),
      child: _StockDetailView(symbol: symbol, fullName: fullName),
    );
  }
}

class _StockDetailView extends StatelessWidget {
  final String symbol;
  final String fullName;

  const _StockDetailView({required this.symbol, required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context),
      body: BlocBuilder<StockDetailBloc, StockDetailState>(
        builder: (context, state) {
          return switch (state) {
            StockDetailInitial() => const SizedBox.shrink(),
            StockDetailLoading() => _buildLoader(),
            StockDetailLoaded() => _buildContent(context, state),
            StockDetailError() => _buildError(state.message),
          };
        },
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: AppColors.textPrimary,
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$symbol ',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextSpan(
              text: fullName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add, size: 24),
          color: AppColors.textPrimary,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, size: 24),
          color: AppColors.textPrimary,
          onPressed: () {},
        ),
      ],
    );
  }

  // ── States ────────────────────────────────────────────────────────────────

  Widget _buildLoader() {
    return const Center(
      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildContent(BuildContext context, StockDetailLoaded state) {
    return Column(
      children: [
        // ── Scrollable body ─────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price + tags header
                PriceHeaderWidget(detail: state.detail),

                const SizedBox(height: 12),

                // Chart
                StockChartWidget(
                  points: state.chartPoints,
                  range: state.selectedRange,
                  isGain: state.detail.absoluteGain >= 0,
                ),

                const SizedBox(height: 4),

                // Range tabs
                TimeRangeSelector(
                  selected: state.selectedRange,
                  onChanged: (range) => context.read<StockDetailBloc>().add(
                    StockDetailChartRangeChanged(range),
                  ),
                ),

                const SizedBox(height: 20),

                // Overview / F&O / News tabs
                _OverviewTabBar(),

                const Divider(height: 1, color: Color(0xFFEEEEEE)),

                const SizedBox(height: 20),

                // Position card
                PositionCard(detail: state.detail),

                const SizedBox(height: 100), // bottom padding for FAB
              ],
            ),
          ),
        ),

        // ── Bottom bar ──────────────────────────────────────
        _BottomBar(symbol: state.detail.symbol),
      ],
    );
  }
}

// ── Overview / F&O / News tab row ─────────────────────────────────────────────

class _OverviewTabBar extends StatefulWidget {
  @override
  State<_OverviewTabBar> createState() => _OverviewTabBarState();
}

class _OverviewTabBarState extends State<_OverviewTabBar> {
  int _selected = 0;
  static const _tabs = ['Overview', 'F&O', 'News'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isActive = i == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              padding: const EdgeInsets.only(bottom: 10),
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
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Bottom Bar (Wallet + Trade) ───────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final String symbol;
  const _BottomBar({required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Row(
        children: [
          // ── Wallet dropdown ────────────────────────────────
          GestureDetector(
            onTap: () {},
            child: const Row(
              children: [
                Text(
                  'Wallet',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),

          const Spacer(),

          // ── Trade button ───────────────────────────────────
          SizedBox(
            width: 160,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Trade',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
