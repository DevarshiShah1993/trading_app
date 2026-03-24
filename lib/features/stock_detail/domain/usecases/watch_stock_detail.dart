import '../entities/stock_detail_entity.dart';
import '../repositories/stock_detail_repository.dart';

class WatchStockDetail {
  final StockDetailRepository repository;
  const WatchStockDetail(this.repository);

  /// 1. Fetches initial full detail (with chart + position)
  /// 2. Merges live price stream on top — emits updated entity on each tick
  Stream<StockDetailEntity> call(String symbol) async* {
    // Initial full load
    final detail = await repository.getStockDetail(symbol);
    yield detail;

    // Live price updates
    await for (final price in repository.watchPrice(symbol)) {
      yield detail.copyWithPrice(price);
    }
  }
}