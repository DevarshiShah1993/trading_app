import 'dart:isolate';
import 'dart:math';
import '../../domain/entities/stock_detail_entity.dart';
import '../../domain/entities/chart_point_entity.dart';
import '../../domain/entities/user_position_entity.dart';
import '../models/chart_point_model.dart';
import '../../../watchlist/data/datasources/stock_price_stream_service.dart';

class StockDetailLocalDatasource {
  // ── Static position data per symbol ──────────────────────────────────────
  static const Map<String, Map<String, dynamic>> _positions = {
    'ITC': {'shares': 28, 'avgCost': 400.20, 'portfolioDiversity': 5.16},
    'TCS': {'shares': 5, 'avgCost': 3100.00, 'portfolioDiversity': 8.40},
    'INFY': {'shares': 15, 'avgCost': 1380.00, 'portfolioDiversity': 6.20},
    'ACC': {'shares': 10, 'avgCost': 1950.00, 'portfolioDiversity': 4.10},
    'HUL': {'shares': 8, 'avgCost': 2200.00, 'portfolioDiversity': 3.80},
  };

  static const Map<String, List<String>> _tags = {
    'ITC': ['INDUSTRIAL', 'LARGE CAP'],
    'TCS': ['IT', 'LARGE CAP'],
    'INFY': ['IT', 'LARGE CAP'],
    'ACC': ['CEMENT', 'LARGE CAP'],
    'HUL': ['FMCG', 'LARGE CAP'],
  };

  /// Fetches full detail — chart generation runs in an isolate.
  Future<StockDetailEntity> fetchDetail(String symbol) async {
    final currentPrice = StockPriceStreamService.seedPrices[symbol] ?? 1000.0;

    // Run chart generation in isolate (heavy computation off main thread)
    final allChartData = await _generateAllChartDataInIsolate(
      symbol: symbol,
      currentPrice: currentPrice,
    );

    final posData = _positions[symbol] ?? _positions['ITC']!;
    final shares = posData['shares'] as int;
    final avgCost = posData['avgCost'] as double;
    final diversity = posData['portfolioDiversity'] as double;

    final todayReturn = (currentPrice - avgCost) * shares * 0.003;
    final totalReturn = (currentPrice - avgCost) * shares;
    final todayReturnPct = (todayReturn / (avgCost * shares)) * 100;
    final totalReturnPct = ((currentPrice - avgCost) / avgCost) * 100;

    final position = UserPositionEntity(
      shares: shares,
      avgCost: avgCost,
      portfolioDiversity: diversity,
      todayReturn: double.parse(todayReturn.toStringAsFixed(2)),
      todayReturnPercent: double.parse(todayReturnPct.toStringAsFixed(2)),
      totalReturn: double.parse(totalReturn.toStringAsFixed(2)),
      totalReturnPercent: double.parse(totalReturnPct.toStringAsFixed(2)),
    );

    return StockDetailEntity(
      symbol: symbol,
      fullName: _fullName(symbol),
      exchange: 'NSE',
      tags: _tags[symbol] ?? ['LARGE CAP'],
      currentPrice: currentPrice,
      allTimeBasePrice: avgCost,
      position: position,
      chartData: allChartData,
    );
  }

  // ── Chart data via Isolate ────────────────────────────────────────────────

  Future<Map<ChartRange, List<ChartPointEntity>>>
  _generateAllChartDataInIsolate({
    required String symbol,
    required double currentPrice,
  }) async {
    final receivePort = ReceivePort();

    await Isolate.spawn(
      _isolateEntryPoint,
      _IsolatePayload(
        sendPort: receivePort.sendPort,
        symbol: symbol,
        currentPrice: currentPrice,
      ),
    );

    final raw = await receivePort.first as Map<String, List<List<dynamic>>>;

    return {
      for (final entry in raw.entries)
        _rangeFromKey(entry.key): entry.value
            .map(
              (p) => ChartPointModel(
                timestamp: DateTime.parse(p[0] as String),
                price: (p[1] as num).toDouble(),
              ).toEntity(),
            )
            .toList(),
    };
  }

  /// Top-level function required for Isolate.spawn
  static void _isolateEntryPoint(_IsolatePayload payload) {
    final result = <String, List<List<dynamic>>>{};
    final random = Random(payload.symbol.hashCode);

    for (final range in ChartRange.values) {
      result[range.name] = _buildPoints(
        range: range,
        endPrice: payload.currentPrice,
        random: random,
      );
    }

    payload.sendPort.send(result);
  }

  static List<List<dynamic>> _buildPoints({
    required ChartRange range,
    required double endPrice,
    required Random random,
  }) {
    final config = _rangeConfig(range);
    final count = config['count'] as int;
    final duration = config['duration'] as Duration;
    final volatility = config['volatility'] as double;

    final now = DateTime.now();
    final points = <List<dynamic>>[];

    // Walk BACKWARDS from current price
    double price = endPrice;
    for (int i = count; i >= 0; i--) {
      final timestamp = now.subtract(duration * i);
      points.add([timestamp.toIso8601String(), price]);

      // Random walk for next (earlier) point
      final bps = volatility * random.nextDouble();
      final direction = random.nextBool() ? 1.0 : -1.0;
      price = double.parse((price * (1 - direction * bps)).toStringAsFixed(2));
      // Keep price sane — floor at 50% of end price
      price = price.clamp(endPrice * 0.5, endPrice * 1.5);
    }

    return points;
  }

  static Map<String, dynamic> _rangeConfig(ChartRange range) {
    switch (range) {
      case ChartRange.oneDay:
        return {
          'count': 78,
          'duration': const Duration(minutes: 5),
          'volatility': 0.0008,
        };
      case ChartRange.oneWeek:
        return {
          'count': 35,
          'duration': const Duration(hours: 3),
          'volatility': 0.0015,
        };
      case ChartRange.oneMonth:
        return {
          'count': 30,
          'duration': const Duration(days: 1),
          'volatility': 0.0025,
        };
      case ChartRange.threeMonth:
        return {
          'count': 90,
          'duration': const Duration(days: 1),
          'volatility': 0.0030,
        };
      case ChartRange.sixMonth:
        return {
          'count': 180,
          'duration': const Duration(days: 1),
          'volatility': 0.0035,
        };
      case ChartRange.ytd:
        return {
          'count': 80,
          'duration': const Duration(days: 1),
          'volatility': 0.0030,
        };
      case ChartRange.oneYear:
        return {
          'count': 365,
          'duration': const Duration(days: 1),
          'volatility': 0.0040,
        };
    }
  }

  ChartRange _rangeFromKey(String key) =>
      ChartRange.values.firstWhere((r) => r.name == key);

  String _fullName(String symbol) {
    const names = {
      'ITC': 'ITC Ltd.',
      'TCS': 'Tata Consultancy Services',
      'INFY': 'Infosys',
      'ACC': 'ACC Ltd.',
      'HUL': 'Hindustan Unilever Ltd.',
    };
    return names[symbol] ?? symbol;
  }
}

// ── Isolate message payload ───────────────────────────────────────────────────

class _IsolatePayload {
  final SendPort sendPort;
  final String symbol;
  final double currentPrice;

  const _IsolatePayload({
    required this.sendPort,
    required this.symbol,
    required this.currentPrice,
  });
}
