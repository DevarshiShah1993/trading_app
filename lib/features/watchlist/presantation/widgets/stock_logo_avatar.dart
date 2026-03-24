import 'package:flutter/material.dart';

class StockLogoAvatar extends StatelessWidget {
  final String symbol;
  final String hexColor;
  final double size;

  const StockLogoAvatar({
    super.key,
    required this.symbol,
    required this.hexColor,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseHex(hexColor);
    final label = symbol.length > 3 ? symbol.substring(0, 3) : symbol;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _parseHex(String hex) {
    try {
      final cleaned = hex.replaceFirst('#', '');
      final value = int.parse(
        cleaned.length == 6 ? 'FF$cleaned' : cleaned,
        radix: 16,
      );
      return Color(value);
    } catch (_) {
      return const Color(0xFF607D8B); // fallback blue-grey
    }
  }
}
