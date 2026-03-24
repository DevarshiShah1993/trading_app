import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/features/watchlist/domain/entities/stock_entity.dart';
import 'package:trading_app/features/watchlist/domain/usecases/watch_stock_prices.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final WatchStockPrices _watchStockPrices;

  // Holds the stream subscription so we can cancel it in close()
  StreamSubscription<List<StockEntity>>? _priceSubscription;

  WatchlistBloc(this._watchStockPrices) : super(const WatchlistInitial()) {
    on<WatchlistStarted>(_onStarted);
    on<WatchlistRefreshRequested>(_onRefreshRequested);
    on<WatchlistPriceUpdated>(_onPriceUpdated);
  }

  // ── Event Handlers ────────────────────────────────────────────────────────

  Future<void> _onStarted(
    WatchlistStarted event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(const WatchlistLoading());
    await _subscribeToStream(emit);
  }

  Future<void> _onRefreshRequested(
    WatchlistRefreshRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    // Cancel existing subscription before restarting
    await _priceSubscription?.cancel();
    emit(const WatchlistLoading());
    await _subscribeToStream(emit);
  }

  void _onPriceUpdated(
    WatchlistPriceUpdated event,
    Emitter<WatchlistState> emit,
  ) {
    final stocks = event.stocks.cast<StockEntity>();

    if (state is WatchlistLoaded) {
      emit((state as WatchlistLoaded).copyWith(stocks: stocks, isLive: true));
    }
  }

  // ── Stream Subscription ───────────────────────────────────────────────────

  Future<void> _subscribeToStream(Emitter<WatchlistState> emit) async {
    // emit() inside async* / stream is handled via the subscription pattern
    // We use add(event) inside the listener — standard BLoC stream approach
    await emit.forEach<List<StockEntity>>(
      _watchStockPrices(),
      onData: (stocks) {
        if (state is WatchlistLoading) {
          // First emission — transition from loading to loaded
          return WatchlistLoaded(stocks: stocks, isLive: false);
        }
        return WatchlistLoaded(stocks: stocks, isLive: true);
      },
      onError: (error, stackTrace) => WatchlistError(error.toString()),
    );
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    await _priceSubscription?.cancel();
    return super.close();
  }
}
