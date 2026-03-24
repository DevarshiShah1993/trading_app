import 'dart:async';
import '../../domain/entities/stock_entity.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/stock_price_stream_service.dart';
import '../models/stock_model.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final StockPriceStreamService _streamService;

  WatchlistRepositoryImpl(this._streamService);

  // ── Static seed data ──────────────────────────────────────────────────────
  // logoAsset = hex color used by the avatar widget (no actual images needed)
  static final List<StockModel> _seedStocks = [
    StockModel(
      symbol: 'ACC',
      fullName: 'ACC Ltd.',
      exchange: 'NSE',
      logoAsset: '#E53935', // red
      currentPrice: 2061.70,
      change: 2.45,
      changePercent: 0.12,
    ),
    StockModel(
      symbol: 'INFY',
      fullName: 'Infosys',
      exchange: 'NSE',
      logoAsset: '#1565C0', // blue
      currentPrice: 1419.50,
      change: -6.40,
      changePercent: -0.45,
    ),
    StockModel(
      symbol: 'ITC',
      fullName: 'ITC Ltd.',
      exchange: 'NSE',
      logoAsset: '#1A237E', // dark blue
      currentPrice: 441.60,
      change: 2.90,
      changePercent: 0.66,
    ),
    StockModel(
      symbol: 'HUL',
      fullName: 'Hindustan Unilever Ltd.',
      exchange: 'NSE',
      logoAsset: '#1565C0', // blue
      currentPrice: 2375.00,
      change: 8.30,
      changePercent: 0.35,
    ),
    StockModel(
      symbol: 'TCS',
      fullName: 'Tata Consultancy Services',
      exchange: 'NSE',
      logoAsset: '#0288D1', // light blue
      currentPrice: 3298.90,
      change: 25.20,
      changePercent: 0.77,
    ),
  ];

  // Today's open prices — used as baseline for change % calculation
  static const Map<String, double> _openPrices = {
    'ACC': 2059.25,
    'INFY': 1425.90,
    'ITC': 438.70,
    'HUL': 2366.70,
    'TCS': 3273.70,
  };

  @override
  Future<List<StockEntity>> getWatchlist() async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 300));
    return _seedStocks.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<StockEntity> watchStockPrice(String symbol) {
    final model = _seedStocks.firstWhere((s) => s.symbol == symbol);
    final open = _openPrices[symbol] ?? model.currentPrice;

    return _streamService.getStream(symbol).map((newPrice) {
      return model
          .copyWithNewPrice(newPrice: newPrice, basePrice: open)
          .toEntity();
    });
  }
}
