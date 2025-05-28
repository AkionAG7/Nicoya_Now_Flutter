import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../entities/driver/driver.dart';

/// Repository interface for managing driver data
abstract class DriverRepository {
  /// Get a list of all drivers in the system
  Future<Either<Failure, List<Driver>>> getAllDrivers();
  
  /// Get a driver by their ID
  Future<Either<Failure, Driver>> getDriverById(String driverId);
  
  /// Approve a driver's verification status
  Future<Either<Failure, Driver>> approveDriver(String driverId);
  
  /// Reject a driver's verification status
  Future<Either<Failure, Driver>> rejectDriver(String driverId);
  
  /// Create a new driver in the system
  Future<Either<Failure, Driver>> createDriver(Driver driver);
  
  /// Update an existing driver's information
  Future<Either<Failure, Driver>> updateDriver(Driver driver);
  
  /// Delete a driver from the system
  Future<Either<Failure, bool>> deleteDriver(String driverId);
}
