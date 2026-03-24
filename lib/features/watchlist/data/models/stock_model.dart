import '../../domain/entities/stock_entity.dart';

/// Data model — owns serialization concerns.
/// Maps cleanly to/from domain entity.
class StockModel {
  final String symbol;
  final String fullName;
  final String exchange;
  final String logoAsset; // hex color string used to build avatar
  final double currentPrice;
  final double change;
  final double changePercent;

  const StockModel({
    required this.symbol,
    required this.fullName,
    required this.exchange,
    required this.logoAsset,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
  });

  /// Map FROM domain entity (e.g. when rebuilding after stream tick)
  factory StockModel.fromEntity(StockEntity entity) => StockModel(
    symbol: entity.symbol,
    fullName: entity.fullName,
    exchange: entity.exchange,
    logoAsset: entity.logoAsset,
    currentPrice: entity.currentPrice,
    change: entity.change,
    changePercent: entity.changePercent,
  );

  /// Map TO domain entity — the only object presentation ever sees
  StockEntity toEntity() => StockEntity(
    symbol: symbol,
    fullName: fullName,
    exchange: exchange,
    logoAsset: logoAsset,
    currentPrice: currentPrice,
    change: change,
    changePercent: changePercent,
  );

  /// Rebuild model with new live price, recalculate change fields
  StockModel copyWithNewPrice({
    required double newPrice,
    required double basePrice, // today's open price
  }) {
    final change = double.parse((newPrice - basePrice).toStringAsFixed(2));
    final changePct = double.parse(
      ((change / basePrice) * 100).toStringAsFixed(2),
    );
    return StockModel(
      symbol: symbol,
      fullName: fullName,
      exchange: exchange,
      logoAsset: logoAsset,
      currentPrice: newPrice,
      change: change,
      changePercent: changePct,
    );
  }
}
