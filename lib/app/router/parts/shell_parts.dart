part of base.router;

///
///  dart run build_runner build -d
///

@TypedStatefulShellRoute<ShellRoute>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<HomeBranch>(
      routes: <TypedRoute<RouteData>>[homeRoute],
    ),
    TypedStatefulShellBranch<ProfileBranch>(
      routes: <TypedRoute<RouteData>>[profileRoute],
    ),
  ],
)
class ShellRoute extends StatefulShellRouteData {
  const ShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return navigationShell;
  }

  static Widget $navigatorContainerBuilder(
    BuildContext context,
    StatefulNavigationShell navigationShell,
    List<Widget> children,
  ) {
    return ShellScaffold(navigationShell: navigationShell, children: children);
  }
}

final class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();
}

final class ProfileBranch extends StatefulShellBranchData {
  const ProfileBranch();
}
