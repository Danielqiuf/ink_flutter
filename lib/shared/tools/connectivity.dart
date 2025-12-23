import 'package:connectivity_plus/connectivity_plus.dart';

///
/// 网络连接+检测相关工具
///

Future<List<ConnectivityResult>> getConnectivityResult() =>
    Connectivity().checkConnectivity();

Future<bool> isNetworkConnected() async {
  List<ConnectivityResult> connectivityResult = await getConnectivityResult();
  return !connectivityResult.contains(ConnectivityResult.none);
}
