part of base_router;

const profileRoute = TypedGoRoute<ProfileRoute>(path: '/profile');

class ProfileRoute extends GoRouteData with _$ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen();
}
