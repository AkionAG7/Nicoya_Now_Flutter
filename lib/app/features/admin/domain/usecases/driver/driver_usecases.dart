import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../entities/driver/driver.dart';
import '../../repositories/driver/driver_repository.dart';

/// Use case to get all drivers
class GetAllDriversUseCase {
  final DriverRepository repository;

  const GetAllDriversUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, List<Driver>>> call() {
    return repository.getAllDrivers();
  }
}

/// Use case to get a specific driver by ID
class GetDriverByIdUseCase {
  final DriverRepository repository;

  const GetDriverByIdUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, Driver>> call(String driverId) {
    return repository.getDriverById(driverId);
  }
}

/// Use case to approve a driver (set isVerified to true)
class ApproveDriverUseCase {
  final DriverRepository repository;

  const ApproveDriverUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, Driver>> call(String driverId) {
    return repository.approveDriver(driverId);
  }
}

/// Use case to reject a driver (set isVerified to false)
class RejectDriverUseCase {
  final DriverRepository repository;

  const RejectDriverUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, Driver>> call(String driverId) {
    return repository.rejectDriver(driverId);
  }
}
