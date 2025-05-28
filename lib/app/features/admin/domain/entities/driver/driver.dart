/// Entity representing a driver in the system
class Driver {
  /// Unique identifier for the driver
  final String driverId;
  
  /// Type of vehicle the driver operates
  final String vehicleType;
  
  /// Driver's license number (optional)
  final String? licenseNumber;
  
  /// URL to driver's documents (optional)
  final String? docsUrl;
  
  /// Whether the driver has been verified/approved to access the system
  final bool isVerified;
  
  /// When the driver was created in the system
  final DateTime createdAt;

  /// Creates a new [Driver] instance
  const Driver({
    required this.driverId,
    required this.vehicleType,
    this.licenseNumber,
    this.docsUrl,
    required this.isVerified,
    required this.createdAt,
  });

  /// Creates a copy of this Driver with the given fields replaced with new values
  Driver copyWith({
    String? driverId,
    String? vehicleType,
    String? licenseNumber,
    String? docsUrl,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return Driver(
      driverId: driverId ?? this.driverId,
      vehicleType: vehicleType ?? this.vehicleType,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      docsUrl: docsUrl ?? this.docsUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Driver &&
        other.driverId == driverId &&
        other.vehicleType == vehicleType &&
        other.licenseNumber == licenseNumber &&
        other.docsUrl == docsUrl &&
        other.isVerified == isVerified &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return driverId.hashCode ^
        vehicleType.hashCode ^
        licenseNumber.hashCode ^
        docsUrl.hashCode ^
        isVerified.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'Driver(driverId: $driverId, vehicleType: $vehicleType, licenseNumber: $licenseNumber, docsUrl: $docsUrl, isVerified: $isVerified, createdAt: $createdAt)';
  }
}
