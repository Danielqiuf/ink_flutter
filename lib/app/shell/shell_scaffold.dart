import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  static const _destinations = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Explore'),
    NavigationDestination(icon: Icon(Icons.person_outline), label: 'Me'),
  ];

  void _goBranch(int index) {
    // 官方示例推荐 goBranch + initialLocation 模式 :contentReference[oaicite:10]{index=10}
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final useRail = width >= 700;

    final body = AnimatedBranchContainer(
      currentIndex: navigationShell.currentIndex,
      children: children,
    );

    if (!useRail) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          destinations: _destinations,
          onDestinationSelected: _goBranch,
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.explore_outlined),
                label: Text('Explore'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                label: Text('Me'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class AnimatedBranchContainer extends StatelessWidget {
  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (int i = 0; i < children.length; i++)
          IgnorePointer(
            ignoring: i != currentIndex,
            child: TickerMode(
              enabled: i == currentIndex,
              child: AnimatedOpacity(
                opacity: i == currentIndex ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                child: AnimatedScale(
                  scale: i == currentIndex ? 1 : 1.02,
                  duration: const Duration(milliseconds: 220),
                  child: children[i],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
