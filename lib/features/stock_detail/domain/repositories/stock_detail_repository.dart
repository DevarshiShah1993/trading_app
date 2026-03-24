import '../entities/stock_detail_entity.dart';
import '../entities/chart_point_entity.dart';

abstract class StockDetailRepository {
  Future<StockDetailEntity> getStockDetail(String symbol);

  Future<List<ChartPointEntity>> getChartHistory(
    String symbol,
    ChartRange range,
  );

  Stream<double> watchPrice(String symbol);
}
