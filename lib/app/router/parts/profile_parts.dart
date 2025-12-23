part of base.router;

const profileRoute = TypedGoRoute<ProfileRoute>(path: '/profile');

class ProfileRoute extends StyledRouteData with _$ProfileRoute {
  const ProfileRoute();

  @override
  StatusBarTheme get statusBarTheme => StatusBarTheme.light;

  @override
  Widget buildScreen(BuildContext context, GoRouterState state) =>
      const ProfileScreen();
}
