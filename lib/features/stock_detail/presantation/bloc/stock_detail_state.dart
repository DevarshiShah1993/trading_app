import 'package:equatable/equatable.dart';
import 'package:trading_app/features/stock_detail/domain/entities/chart_point_entity.dart';
import 'package:trading_app/features/stock_detail/domain/entities/stock_detail_entity.dart';

sealed class StockDetailState extends Equatable {
  const StockDetailState();

  @override
  List<Object?> get props => [];
}

final class StockDetailInitial extends StockDetailState {
  const StockDetailInitial();
}

final class StockDetailLoading extends StockDetailState {
  const StockDetailLoading();
}

/// Primary state — holds both static detail + live price data.
final class StockDetailLoaded extends StockDetailState {
  final StockDetailEntity detail;
  final ChartRange selectedRange;
  final List<ChartPointEntity> chartPoints; // pre-sliced for selected range
  final bool isLive;

  const StockDetailLoaded({
    required this.detail,
    required this.selectedRange,
    required this.chartPoints,
    this.isLive = false,
  });

  /// Called on every price tick — minimal rebuild surface
  StockDetailLoaded copyWithPrice(double newPrice) {
    return StockDetailLoaded(
      detail: detail.copyWithPrice(newPrice),
      selectedRange: selectedRange,
      chartPoints: chartPoints,
      isLive: true,
    );
  }

  /// Called when user switches chart range tab
  StockDetailLoaded copyWithRange({
    required ChartRange range,
    required List<ChartPointEntity> points,
  }) {
    return StockDetailLoaded(
      detail: detail,
      selectedRange: range,
      chartPoints: points,
      isLive: isLive,
    );
  }

  @override
  List<Object?> get props => [detail, selectedRange, chartPoints, isLive];
}

final class StockDetailError extends StockDetailState {
  final String message;
  const StockDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
