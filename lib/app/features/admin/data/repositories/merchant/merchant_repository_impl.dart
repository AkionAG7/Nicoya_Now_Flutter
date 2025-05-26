import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../../domain/entities/merchant/merchant.dart';
import '../../../domain/repositories/merchant/merchant_repository.dart';
import '../../datasources/merchant/merchant_remote_datasource.dart';
import '../../models/merchant_model.dart';

/// Implementation of [MerchantRepository]
class MerchantRepositoryImpl implements MerchantRepository {
  final MerchantRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MerchantRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Merchant>>> getAllMerchants() async {
    if (await networkInfo.isConnected) {
      try {
        final merchants = await remoteDataSource.getAllMerchants();
        return Right(merchants);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Merchant>> getMerchantById(String merchantId) async {
    if (await networkInfo.isConnected) {
      try {
        final merchant = await remoteDataSource.getMerchantById(merchantId);
        return Right(merchant);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Merchant>> approveMerchant(String merchantId) async {
    if (await networkInfo.isConnected) {
      try {
        final merchant = await remoteDataSource.approveMerchant(merchantId);
        return Right(merchant);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Merchant>> rejectMerchant(String merchantId) async {
    if (await networkInfo.isConnected) {
      try {
        final merchant = await remoteDataSource.rejectMerchant(merchantId);
        return Right(merchant);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Merchant>> createMerchant(Merchant merchant) async {
    if (await networkInfo.isConnected) {
      try {
        final merchantModel = MerchantModel.fromEntity(merchant);
        final createdMerchant = await remoteDataSource.createMerchant(merchantModel);
        return Right(createdMerchant);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Merchant>> updateMerchant(Merchant merchant) async {
    if (await networkInfo.isConnected) {
      try {
        final merchantModel = MerchantModel.fromEntity(merchant);
        final updatedMerchant = await remoteDataSource.updateMerchant(merchantModel);
        return Right(updatedMerchant);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMerchant(String merchantId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteMerchant(merchantId);
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
