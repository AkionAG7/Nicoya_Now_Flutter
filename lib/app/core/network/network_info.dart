import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Abstract class for checking network connectivity
abstract class NetworkInfo {
  /// Check if the device is connected to the internet
  Future<bool> get isConnected;
}

/// Implementation of [NetworkInfo]
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  const NetworkInfoImpl({required this.connectionChecker});

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
