/// Abstract class for checking network connectivity
abstract class NetworkInfo {
  /// Check if the device is connected to the internet
  Future<bool> get isConnected;
}

/// Implementation of [NetworkInfo]
class NetworkInfoImpl implements NetworkInfo {
  final dynamic connectionChecker; // Replace with actual connectivity checking package type

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
