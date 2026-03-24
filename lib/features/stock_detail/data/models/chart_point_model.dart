import '../../domain/entities/chart_point_entity.dart';

class ChartPointModel {
  final DateTime timestamp;
  final double price;

  const ChartPointModel({required this.timestamp, required this.price});

  ChartPointEntity toEntity() =>
      ChartPointEntity(timestamp: timestamp, price: price);
}