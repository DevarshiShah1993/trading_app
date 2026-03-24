import 'package:equatable/equatable.dart';

/// Represents a single stock row in the watchlist.
/// This is the canonical truth object — data layer maps TO this.
class StockEntity extends Equatable {
  final String symbol; // e.g. "TCS"
  final String fullName; // e.g. "Tata Consultancy Services"
  final String exchange; // "NSE" | "BSE"
  final String logoAsset; // asset path or color-code for avatar
  final double currentPrice;
  final double change; // absolute price change
  final double changePercent; // % change

  const StockEntity({
    required this.symbol,
    required this.fullName,
    required this.exchange,
    required this.logoAsset,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
  });

  bool get isGain => changePercent >= 0;

  /// Creates updated copy when stream emits new tick
  StockEntity copyWith({
    double? currentPrice,
    double? change,
    double? changePercent,
  }) {
    return StockEntity(
      symbol: symbol,
      fullName: fullName,
      exchange: exchange,
      logoAsset: logoAsset,
      currentPrice: currentPrice ?? this.currentPrice,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
    );
  }

  @override
  List<Object?> get props => [
    symbol,
    exchange,
    currentPrice,
    change,
    changePercent,
  ];
}
