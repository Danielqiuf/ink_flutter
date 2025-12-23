import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink_self_projects/app/session/session_provider.dart';

///
/// app启动时请求的接口
///
final bootstrapProvider = FutureProvider((ref) async {
  await ref.read(userinfoProvider.future);
});
