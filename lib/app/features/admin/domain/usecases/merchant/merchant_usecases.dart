import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../entities/merchant/merchant.dart';
import '../../repositories/merchant/merchant_repository.dart';

/// Use case to get all merchants
class GetAllMerchantsUseCase {
  final MerchantRepository repository;

  const GetAllMerchantsUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, List<Merchant>>> call() {
    return repository.getAllMerchants();
  }
}

/// Use case to get a specific merchant by ID
class GetMerchantByIdUseCase {
  final MerchantRepository repository;

  const GetMerchantByIdUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, Merchant>> call(String merchantId) {
    return repository.getMerchantById(merchantId);
  }
}

/// Use case to approve a merchant (set isVerified to true)
class ApproveMerchantUseCase {
  final MerchantRepository repository;

  const ApproveMerchantUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, Merchant>> call(String merchantId) {
    return repository.approveMerchant(merchantId);
  }
}

/// Use case to reject a merchant (set isVerified to false)
class RejectMerchantUseCase {
  final MerchantRepository repository;

  const RejectMerchantUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, Merchant>> call(String merchantId) {
    return repository.rejectMerchant(merchantId);
  }
}
