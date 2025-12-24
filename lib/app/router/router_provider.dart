import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';

final rootNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (ref) => GlobalKey<NavigatorState>(debugLabel: 'rootNav'),
);

class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final routerRefreshProvider = Provider<RouterRefreshNotifier>((ref) {
  final n = RouterRefreshNotifier();

  // ref.listen(authStateProvider, (_, __) => n.refresh());
  ref.onDispose(n.dispose);

  return n;
});

final routerProvider = Provider.family<GoRouter, String>((
  ref,
  initialLocation,
) {
  final rootKey = ref.read(rootNavigatorKeyProvider);
  final refresh = ref.read(routerRefreshProvider);

  return GoRouter(
    navigatorKey: rootKey,
    routes: $appRoutes,
    initialLocation: initialLocation,
    refreshListenable: refresh,
    redirect: (context, state) {
      return null;
    },
  );
});
