import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink_self_projects/apis/user/user_models.dart';
import 'package:ink_self_projects/core/network/cancelable.dart';

import '../../core/di/dio_provider.dart';

final userinfoProvider =
    AsyncNotifierProvider<UserinfoController, UserinfoModel?>(
      UserinfoController.new,
    );

class UserinfoController extends CancelableAsyncNotifier<UserinfoModel?> {
  @override
  FutureOr<UserinfoModel?> build() async => _fetch();

  Future<UserinfoModel?> _fetch() async {
    final ct = cancelToken.next();
    final hub = ref.read(apiHubProvider);
    return await hub.user.getUserInfo(ct: ct);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
