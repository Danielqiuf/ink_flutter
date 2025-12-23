import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

///
/// 整体Tab基层页
///
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
    NavigationDestination(icon: Icon(Icons.person_outline), label: 'Me'),
  ];

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = AnimatedBranchContainer(
      currentIndex: navigationShell.currentIndex,
      children: children,
    );

    return Scaffold(
      body: body,
      extendBody: true,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: _destinations,
        onDestinationSelected: _goBranch,
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
      fit: StackFit.expand,
      children: [
        for (int i = 0; i < children.length; i++)
          IgnorePointer(
            ignoring: i != currentIndex,
            child: AnimatedOpacity(
              opacity: i == currentIndex ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              child: AnimatedScale(
                scale: i == currentIndex ? 1 : 1.02,
                duration: const Duration(milliseconds: 220),
                child: TickerMode(
                  enabled: i == currentIndex,
                  child: children[i],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
