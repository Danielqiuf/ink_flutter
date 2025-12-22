import 'package:connectivity_plus/connectivity_plus.dart';

Future<List<ConnectivityResult>> getConnectivityResult() =>
    Connectivity().checkConnectivity();

Future<bool> isNetworkConnected() async {
  List<ConnectivityResult> connectivityResult = await getConnectivityResult();
  return !connectivityResult.contains(ConnectivityResult.none);
}
