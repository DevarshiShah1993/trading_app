import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/features/watchlist/presantation/pages/watchlist_page.dart';
import 'core/di/service_locator.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/utils/app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  Bloc.observer = AppBlocObserver();
  await di.init();
  runApp(const TradingApp());
}

class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trading App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const WatchlistPage(),
    );
  }
}
