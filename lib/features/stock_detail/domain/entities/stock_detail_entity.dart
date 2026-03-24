import 'package:equatable/equatable.dart';
import 'chart_point_entity.dart';
import 'user_position_entity.dart';

enum ChartRange { oneDay, oneWeek, oneMonth, threeMonth, sixMonth, ytd, oneYear }

class StockDetailEntity extends Equatable {
  final String symbol;
  final String fullName;
  final String exchange;
  final List<String> tags;         // e.g. ["INDUSTRIAL", "LARGE CAP"]
  final double currentPrice;
  final double allTimeBasePrice;   // used to compute +₹228 (14.4%) header
  final UserPositionEntity position;
  final Map<ChartRange, List<ChartPointEntity>> chartData;

  const StockDetailEntity({
    required this.symbol,
    required this.fullName,
    required this.exchange,
    required this.tags,
    required this.currentPrice,
    required this.allTimeBasePrice,
    required this.position,
    required this.chartData,
  });

  double get absoluteGain => currentPrice - allTimeBasePrice;
  double get absoluteGainPercent =>
      ((currentPrice - allTimeBasePrice) / allTimeBasePrice) * 100;

  StockDetailEntity copyWithPrice(double newPrice) => StockDetailEntity(
    symbol: symbol,
    fullName: fullName,
    exchange: exchange,
    tags: tags,
    currentPrice: newPrice,
    allTimeBasePrice: allTimeBasePrice,
    position: position,
    chartData: chartData,
  );

  @override
  List<Object?> get props => [symbol, currentPrice];
}