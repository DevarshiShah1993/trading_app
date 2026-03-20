lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── number_formatter.dart
│
├── features/
│   ├── watchlist/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── stock_model.dart
│   │   │   └── repositories/
│   │   │       └── watchlist_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── stock_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── watchlist_repository.dart       ← abstract
│   │   │   └── usecases/
│   │   │       └── watch_stock_prices.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── watchlist_bloc.dart
│   │       │   ├── watchlist_event.dart
│   │       │   └── watchlist_state.dart
│   │       ├── pages/
│   │       │   └── watchlist_page.dart
│   │       └── widgets/
│   │           └── stock_list_tile.dart
│   │
│   └── stock_detail/
│       ├── data/
│       │   ├── models/
│       │   │   └── stock_detail_model.dart
│       │   └── repositories/
│       │       └── stock_detail_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── stock_detail_entity.dart
│       │   │   └── chart_point_entity.dart
│       │   ├── repositories/
│       │   │   └── stock_detail_repository.dart    ← abstract
│       │   └── usecases/
│       │       ├── get_chart_history.dart
│       │       └── watch_stock_detail.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── stock_detail_bloc.dart
│           │   ├── stock_detail_event.dart
│           │   └── stock_detail_state.dart
│           ├── pages/
│           │   └── stock_detail_page.dart
│           └── widgets/
│               ├── chart_widget.dart
│               ├── time_range_selector.dart
│               └── position_card.dart
│
├── injection/
│   └── injection_container.dart          ← GetIt DI wiring
│
└── main.dart