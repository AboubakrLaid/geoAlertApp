import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkChecker {
  Future<bool> hasInternetConnection() async {
    List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.isNotEmpty && connectivityResult[0] != ConnectivityResult.none;
  }
}