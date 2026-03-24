import '../entities/chart_point_entity.dart';
import '../entities/stock_detail_entity.dart';
import '../repositories/stock_detail_repository.dart';

class GetChartHistory {
  final StockDetailRepository repository;
  const GetChartHistory(this.repository);

  Future<List<ChartPointEntity>> call({
    required String symbol,
    required ChartRange range,
  }) {
    return repository.getChartHistory(symbol, range);
  }
}