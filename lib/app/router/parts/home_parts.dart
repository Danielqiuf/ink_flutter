part of base.router;

const homeRoute = TypedGoRoute<HomeRoute>(
  path: '/home',
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<DetailRoute>(path: '/home/detail/:id'),
  ],
);

class HomeRoute extends StyledRouteData with _$HomeRoute {
  const HomeRoute();

  @override
  StatusBarTheme get statusBarTheme => StatusBarTheme.dark;

  @override
  Widget buildScreen(BuildContext context, GoRouterState state) =>
      const HomeScreen();
}

class DetailRoute extends StyledRouteData with _$DetailRoute {
  const DetailRoute({required this.id});

  final int id;

  @override
  StatusBarTheme get statusBarTheme => StatusBarTheme.light;

  @override
  Widget buildScreen(BuildContext context, GoRouterState state) =>
      const DetailScreen();
}
