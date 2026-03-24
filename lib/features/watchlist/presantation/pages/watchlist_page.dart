import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../stock_detail/presantation/pages/stock_detail_page.dart';
import '../../domain/entities/stock_entity.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';
import '../widgets/stock_list_tile.dart';
import '../widgets/watchlist_search_bar.dart';
import '../widgets/watchlist_tab_bar.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WatchlistBloc>()..add(const WatchlistStarted()),
      child: const _WatchlistView(),
    );
  }
}

class _WatchlistView extends StatefulWidget {
  const _WatchlistView();

  @override
  State<_WatchlistView> createState() => _WatchlistViewState();
}

class _WatchlistViewState extends State<_WatchlistView> {
  int _navIndex = 2; // Watchlist tab active

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search bar
          const WatchlistSearchBar(),

          // Tab bar (List 1 / List 2 + filters)
          const WatchlistTabBar(),

          // Divider
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          // Stock list
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      titleSpacing: 16,
      centerTitle: false,
      title: const Text(
        'Watchlist',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _AddWatchlistButton(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        return switch (state) {
          WatchlistInitial() => const SizedBox.shrink(),
          WatchlistLoading() => _buildLoader(),
          WatchlistLoaded(:final stocks) => _buildList(stocks),
          WatchlistError(:final message) => _buildError(message),
        };
      },
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
    );
  }

  Widget _buildList(List<StockEntity> stocks) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      itemCount: stocks.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        thickness: 1,
        indent: 72, // aligns with text, not avatar
        color: Color(0xFFEEEEEE),
      ),
      itemBuilder: (context, index) {
        final stock = stocks[index];
        return StockListTile(
          key: ValueKey(stock.symbol), // stable key for AnimatedList
          stock: stock,
          onTap: () => _navigateToDetail(context, stock),
        );
      },
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.read<WatchlistBloc>().add(
              const WatchlistRefreshRequested(),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, StockEntity stock) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            StockDetailPage(symbol: stock.symbol, fullName: stock.fullName),
      ),
    );
  }
}

// ── Add Watchlist Button ──────────────────────────────────────────────────────

class _AddWatchlistButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // placeholder
      child: Container(
        width: 60,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.all(Radius.circular(30)),
          // shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add_box_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
