import 'dart:async';
import 'dart:math';

/// Simulates a WebSocket-style market data feed.
/// Single instance shared across both repository impls via DI.
class StockPriceStreamService {
  final _random = Random();

  // Internal per-symbol price controllers
  final Map<String, StreamController<double>> _controllers = {};
  final Map<String, double> _lastPrice = {};
  final Map<String, Timer> _timers = {};

  /// Seed prices for all supported symbols
  static const Map<String, double> seedPrices = {
    'ACC': 2061.70,
    'INFY': 1419.50,
    'ITC': 441.60,
    'HUL': 2375.00,
    'TCS': 3298.90,
    'RELIANCE': 2850.00,
    'HDFC': 1680.00,
    'WIPRO': 460.00,
  };

  /// Returns a broadcast stream of price ticks for [symbol].
  /// Tick interval: ~1–2 seconds (randomized to feel organic).
  Stream<double> getStream(String symbol) {
    if (!_controllers.containsKey(symbol)) {
      _controllers[symbol] = StreamController<double>.broadcast();
      _lastPrice[symbol] = seedPrices[symbol] ?? 1000.0;
      _startTicking(symbol);
    }
    return _controllers[symbol]!.stream;
  }

  void _startTicking(String symbol) {
    _tick(symbol); // emit once immediately
    _schedulNext(symbol);
  }

  void _schedulNext(String symbol) {
    // Random interval 800ms – 2000ms
    final ms = 800 + _random.nextInt(1200);
    _timers[symbol] = Timer(Duration(milliseconds: ms), () {
      if (_controllers[symbol]?.isClosed == false) {
        _tick(symbol);
        _schedulNext(symbol);
      }
    });
  }

  void _tick(String symbol) {
    final last = _lastPrice[symbol]!;

    // Realistic micro-fluctuation: ±0.05% to ±0.25%
    final bps = (0.0005 + _random.nextDouble() * 0.002);
    final direction = _random.nextBool() ? 1 : -1;
    final newPrice = double.parse(
      (last * (1 + direction * bps)).toStringAsFixed(2),
    );

    _lastPrice[symbol] = newPrice;
    _controllers[symbol]?.add(newPrice);
  }

  double currentPrice(String symbol) =>
      _lastPrice[symbol] ?? seedPrices[symbol] ?? 0.0;

  void dispose() {
    for (final t in _timers.values) t.cancel();
    for (final c in _controllers.values) c.close();
    _timers.clear();
    _controllers.clear();
  }
}
