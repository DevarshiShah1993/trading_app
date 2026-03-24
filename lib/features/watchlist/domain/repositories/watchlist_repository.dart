import '../entities/stock_entity.dart';

/// Contract that data layer MUST implement.
/// Presentation and use cases depend only on THIS abstraction — never the impl.
abstract class WatchlistRepository {
  /// Returns the initial static list of watchlisted stocks.
  Future<List<StockEntity>> getWatchlist();

  /// Emits a new [StockEntity] every time the price of [symbol] ticks.
  /// Stream is infinite — caller must cancel subscription when done.
  Stream<StockEntity> watchStockPrice(String symbol);
}
