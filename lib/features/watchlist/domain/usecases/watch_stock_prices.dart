import '../entities/stock_entity.dart';
import '../repositories/watchlist_repository.dart';
import 'dart:async';

/// Use case: load initial watchlist, then attach a live stream per stock.
///
/// Returns a Stream<List<StockEntity>> that emits the full updated list
/// every time any single stock price changes.
class WatchStockPrices {
  final WatchlistRepository repository;

  const WatchStockPrices(this.repository);

  /// [call] is the single public entry point — BLoC calls this only.
  Stream<List<StockEntity>> call() async* {
    // 1. Fetch initial snapshot
    final initialList = await repository.getWatchlist();

    // 2. Maintain mutable working copy in domain — safe since this is
    //    a single-subscriber stream owned by the BLoC.
    final stocks = List<StockEntity>.from(initialList);

    yield stocks; // emit initial state immediately

    // 3. Merge all per-symbol streams into one unified list stream
    // Each symbol gets its own subscription; any tick updates the shared list.
    final streams = stocks
        .map((s) => repository.watchStockPrice(s.symbol))
        .toList();

    // Yield merged updates
    yield* _mergeStockStreams(stocks, streams);
  }

  Stream<List<StockEntity>> _mergeStockStreams(
    List<StockEntity> stocks,
    List<Stream<StockEntity>> streams,
  ) async* {
    // Use async* with a StreamController-style merge pattern
    final controller = _MergedStreamController<List<StockEntity>>();

    for (int i = 0; i < streams.length; i++) {
      final index = i;
      streams[index].listen((updatedStock) {
        stocks[index] = updatedStock;
        // Emit a new list copy on every tick
        controller.add(List<StockEntity>.from(stocks));
      });
    }

    yield* controller.stream;
  }
}

/// Minimal stream controller wrapper — keeps use case self-contained.
class _MergedStreamController<T> {
  final _controller = StreamController<T>.broadcast();

  Stream<T> get stream => _controller.stream;

  void add(T value) => _controller.add(value);
}

// Add this import at the top:
// ignore: depend_on_referenced_packages
