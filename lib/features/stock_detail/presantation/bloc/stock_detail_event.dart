import 'package:equatable/equatable.dart';
import 'package:trading_app/features/stock_detail/domain/entities/stock_detail_entity.dart';

sealed class StockDetailEvent extends Equatable {
  const StockDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when detail page mounts — begins full load + stream.
final class StockDetailStarted extends StockDetailEvent {
  final String symbol;
  const StockDetailStarted(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

/// Dispatched when user taps a chart range tab (1D, 1W, etc.)
final class StockDetailChartRangeChanged extends StockDetailEvent {
  final ChartRange range;
  const StockDetailChartRangeChanged(this.range);

  @override
  List<Object?> get props => [range];
}
