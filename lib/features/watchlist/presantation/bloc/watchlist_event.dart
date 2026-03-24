import 'package:equatable/equatable.dart';

/// All events that can be dispatched to [WatchlistBloc].
sealed class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched once when the Watchlist page mounts.
/// Triggers initial data load + stream subscription.
final class WatchlistStarted extends WatchlistEvent {
  const WatchlistStarted();
}

/// Dispatched when user pulls to refresh (future-proof).
final class WatchlistRefreshRequested extends WatchlistEvent {
  const WatchlistRefreshRequested();
}

/// Internal event — emitted by the stream subscription itself.
/// Never dispatched manually from the UI.
final class WatchlistPriceUpdated extends WatchlistEvent {
  final List<dynamic> stocks; // typed as dynamic here, cast in bloc
  const WatchlistPriceUpdated(this.stocks);

  @override
  List<Object?> get props => [stocks];
}
