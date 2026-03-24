import '../../domain/entities/chart_point_entity.dart';
import '../../domain/entities/stock_detail_entity.dart';
import '../../domain/repositories/stock_detail_repository.dart';
import '../datasources/stock_detail_local_datasource.dart';
import '../../../watchlist/data/datasources/stock_price_stream_service.dart';

class StockDetailRepositoryImpl implements StockDetailRepository {
  final StockDetailLocalDatasource _datasource;
  final StockPriceStreamService _streamService;

  // Simple in-memory cache — avoids re-running isolate on page revisit
  final Map<String, StockDetailEntity> _cache = {};

  StockDetailRepositoryImpl(this._datasource, this._streamService);

  @override
  Future<StockDetailEntity> getStockDetail(String symbol) async {
    if (_cache.containsKey(symbol)) return _cache[symbol]!;

    final detail = await _datasource.fetchDetail(symbol);
    _cache[symbol] = detail;
    return detail;
  }

  @override
  Future<List<ChartPointEntity>> getChartHistory(
    String symbol,
    ChartRange range,
  ) async {
    final detail = await getStockDetail(symbol);
    return detail.chartData[range] ?? [];
  }

  @override
  Stream<double> watchPrice(String symbol) =>
      _streamService.getStream(symbol);
}