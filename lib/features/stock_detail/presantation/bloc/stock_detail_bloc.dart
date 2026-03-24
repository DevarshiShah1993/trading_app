import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/features/stock_detail/domain/entities/stock_detail_entity.dart';
import 'package:trading_app/features/stock_detail/domain/usecases/get_chart_history.dart';
import 'package:trading_app/features/stock_detail/domain/usecases/watch_stock_detail.dart';
import 'stock_detail_event.dart';
import 'stock_detail_state.dart';

class StockDetailBloc extends Bloc<StockDetailEvent, StockDetailState> {
  final WatchStockDetail _watchStockDetail;
  final GetChartHistory _getChartHistory;

  StreamSubscription<StockDetailEntity>? _detailSubscription;

  StockDetailBloc(this._watchStockDetail, this._getChartHistory)
    : super(const StockDetailInitial()) {
    on<StockDetailStarted>(_onStarted);
    on<StockDetailChartRangeChanged>(_onChartRangeChanged);
  }

  // ── Event Handlers ────────────────────────────────────────────────────────

  Future<void> _onStarted(
    StockDetailStarted event,
    Emitter<StockDetailState> emit,
  ) async {
    emit(const StockDetailLoading());

    try {
      await emit.forEach<StockDetailEntity>(
        _watchStockDetail(event.symbol),
        onData: (detail) {
          // First emission — full detail loaded, default to 1D chart
          if (state is StockDetailLoading || state is StockDetailInitial) {
            final points = detail.chartData[ChartRange.oneDay] ?? [];
            return StockDetailLoaded(
              detail: detail,
              selectedRange: ChartRange.oneDay,
              chartPoints: points,
              isLive: false,
            );
          }

          // Subsequent emissions — price tick only, preserve UI state
          if (state is StockDetailLoaded) {
            return (state as StockDetailLoaded).copyWithPrice(
              detail.currentPrice,
            );
          }

          return state; // fallback — should never hit
        },
        onError: (error, _) => StockDetailError(error.toString()),
      );
    } catch (e) {
      emit(StockDetailError(e.toString()));
    }
  }

  Future<void> _onChartRangeChanged(
    StockDetailChartRangeChanged event,
    Emitter<StockDetailState> emit,
  ) async {
    final current = state;
    if (current is! StockDetailLoaded) return;

    // Check if data already cached in entity
    final cached = current.detail.chartData[event.range];

    if (cached != null && cached.isNotEmpty) {
      // Instant switch — no loading flash
      emit(current.copyWithRange(range: event.range, points: cached));
      return;
    }

    // Fetch from repository (hits isolate-generated cache)
    try {
      final points = await _getChartHistory(
        symbol: current.detail.symbol,
        range: event.range,
      );
      // Re-check state hasn't changed during async gap
      if (state is StockDetailLoaded) {
        emit(
          (state as StockDetailLoaded).copyWithRange(
            range: event.range,
            points: points,
          ),
        );
      }
    } catch (e) {
      emit(StockDetailError(e.toString()));
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    await _detailSubscription?.cancel();
    return super.close();
  }
}
