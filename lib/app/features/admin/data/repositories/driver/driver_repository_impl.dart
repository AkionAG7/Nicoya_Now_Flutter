import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../../domain/entities/driver/driver.dart';
import '../../../domain/repositories/driver/driver_repository.dart';
import '../../datasources/driver/driver_remote_datasource.dart';
import '../../models/driver_model.dart';

/// Implementation of [DriverRepository]
class DriverRepositoryImpl implements DriverRepository {
  final DriverRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DriverRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Driver>>> getAllDrivers() async {
    if (await networkInfo.isConnected) {
      try {
        final drivers = await remoteDataSource.getAllDrivers();
        return Right(drivers);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Driver>> getDriverById(String driverId) async {
    if (await networkInfo.isConnected) {
      try {
        final driver = await remoteDataSource.getDriverById(driverId);
        return Right(driver);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Driver>> approveDriver(String driverId) async {
    if (await networkInfo.isConnected) {
      try {
        final driver = await remoteDataSource.approveDriver(driverId);
        return Right(driver);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Driver>> rejectDriver(String driverId) async {
    if (await networkInfo.isConnected) {
      try {
        final driver = await remoteDataSource.rejectDriver(driverId);
        return Right(driver);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Driver>> createDriver(Driver driver) async {
    if (await networkInfo.isConnected) {
      try {
        final driverModel = DriverModel.fromEntity(driver);
        final createdDriver = await remoteDataSource.createDriver(driverModel);
        return Right(createdDriver);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Driver>> updateDriver(Driver driver) async {
    if (await networkInfo.isConnected) {
      try {
        final driverModel = DriverModel.fromEntity(driver);
        final updatedDriver = await remoteDataSource.updateDriver(driverModel);
        return Right(updatedDriver);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDriver(String driverId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteDriver(driverId);
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
