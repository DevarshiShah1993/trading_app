import 'package:equatable/equatable.dart';
import 'package:trading_app/features/watchlist/domain/entities/stock_entity.dart';

/// All possible states of the Watchlist screen.
sealed class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object?> get props => [];
}

/// Before any data has loaded.
final class WatchlistInitial extends WatchlistState {
  const WatchlistInitial();
}

/// Spinner state — shown during initial fetch.
final class WatchlistLoading extends WatchlistState {
  const WatchlistLoading();
}

/// Live data available — primary UI state.
final class WatchlistLoaded extends WatchlistState {
  final List<StockEntity> stocks;
  final bool isLive; // true once stream begins emitting

  const WatchlistLoaded({required this.stocks, this.isLive = false});

  WatchlistLoaded copyWith({List<StockEntity>? stocks, bool? isLive}) {
    return WatchlistLoaded(
      stocks: stocks ?? this.stocks,
      isLive: isLive ?? this.isLive,
    );
  }

  @override
  List<Object?> get props => [stocks, isLive];
}

/// Terminal error state.
final class WatchlistError extends WatchlistState {
  final String message;
  const WatchlistError(this.message);

  @override
  List<Object?> get props => [message];
}
