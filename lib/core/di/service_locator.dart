import 'package:get_it/get_it.dart';
import 'package:trading_app/features/stock_detail/data/datasources/stock_detail_local_datasource.dart';
import 'package:trading_app/features/stock_detail/data/repositories/stock_detail_repository_impl.dart';
import 'package:trading_app/features/stock_detail/domain/repositories/stock_detail_repository.dart';
import 'package:trading_app/features/stock_detail/domain/usecases/get_chart_history.dart';
import 'package:trading_app/features/stock_detail/domain/usecases/watch_stock_detail.dart';
import 'package:trading_app/features/stock_detail/presantation/bloc/stock_detail_bloc.dart';
import 'package:trading_app/features/watchlist/data/datasources/stock_price_stream_service.dart';
import 'package:trading_app/features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'package:trading_app/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:trading_app/features/watchlist/domain/usecases/watch_stock_prices.dart';
import 'package:trading_app/features/watchlist/presantation/bloc/watchlist_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {

  // ── Core / Shared ─────────────────────────────────────────────────────────
  // Singleton: one stream engine for the entire app lifetime
  sl.registerLazySingleton<StockPriceStreamService>(
    () => StockPriceStreamService(),
  );

  // ── Watchlist ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<WatchlistRepository>(
    () => WatchlistRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => WatchStockPrices(sl()));
  sl.registerFactory(() => WatchlistBloc(sl()));

  // ── Stock Detail ──────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => StockDetailLocalDatasource());
  sl.registerLazySingleton<StockDetailRepository>(
    () => StockDetailRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => GetChartHistory(sl()));
  sl.registerLazySingleton(() => WatchStockDetail(sl()));
  // Factory: new BLoC instance per page navigation
  sl.registerFactory(() => StockDetailBloc(sl(), sl()));
}