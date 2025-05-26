/// Abstract class for checking network connectivity
abstract class NetworkInfo {
  /// Check if the device is connected to the internet
  Future<bool> get isConnected;
}

/// Implementation of [NetworkInfo]
class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl();

  @override
  Future<bool> get isConnected async {
    // Simple implementation that assumes we have connection
    // In a real app, you might want to use connectivity_plus package
    return true;
  }
}
