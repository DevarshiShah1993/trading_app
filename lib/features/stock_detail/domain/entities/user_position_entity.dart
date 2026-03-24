import 'package:equatable/equatable.dart';

/// Represents the user's holding in a specific stock.
class UserPositionEntity extends Equatable {
  final int shares;
  final double avgCost;           // average buy price
  final double portfolioDiversity; // % of total portfolio
  final double todayReturn;
  final double todayReturnPercent;
  final double totalReturn;
  final double totalReturnPercent;

  const UserPositionEntity({
    required this.shares,
    required this.avgCost,
    required this.portfolioDiversity,
    required this.todayReturn,
    required this.todayReturnPercent,
    required this.totalReturn,
    required this.totalReturnPercent,
  });

  /// Market value = shares × current price (computed at presentation layer
  /// using live price from stream — NOT stored here to avoid stale data)
  double marketValue(double currentPrice) => shares * currentPrice;

  @override
  List<Object?> get props => [
    shares, avgCost, portfolioDiversity,
    todayReturn, totalReturn,
  ];
}