import '../../domain/entities/driver/driver.dart';

/// Data model for a [Driver] entity
class DriverModel extends Driver {
  /// Creates a new [DriverModel] instance
  const DriverModel({
    required super.driverId,
    required super.vehicleType,
    super.licenseNumber,
    super.docsUrl,
    required super.isVerified,
    required super.createdAt,
  });

  /// Creates a [DriverModel] from a JSON map
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      driverId: json['driver_id'],
      vehicleType: json['vehicle_type'],
      licenseNumber: json['license_number'],
      docsUrl: json['docs_url'],
      isVerified: json['is_verified'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'vehicle_type': vehicleType,
      'license_number': licenseNumber,
      'docs_url': docsUrl,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  /// Creates a model from an entity
  factory DriverModel.fromEntity(Driver driver) {
    return DriverModel(
      driverId: driver.driverId,
      vehicleType: driver.vehicleType,
      licenseNumber: driver.licenseNumber,
      docsUrl: driver.docsUrl,
      isVerified: driver.isVerified,
      createdAt: driver.createdAt,
    );
  }
}
