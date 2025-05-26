import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../entities/merchant/merchant.dart';

/// Repository interface for managing merchant data
abstract class MerchantRepository {
  /// Get a list of all merchants in the system
  Future<Either<Failure, List<Merchant>>> getAllMerchants();
  
  /// Get a merchant by their ID
  Future<Either<Failure, Merchant>> getMerchantById(String merchantId);
  
  /// Approve a merchant's verification status
  Future<Either<Failure, Merchant>> approveMerchant(String merchantId);
  
  /// Reject a merchant's verification status
  Future<Either<Failure, Merchant>> rejectMerchant(String merchantId);
  
  /// Create a new merchant in the system
  Future<Either<Failure, Merchant>> createMerchant(Merchant merchant);
  
  /// Update an existing merchant's information
  Future<Either<Failure, Merchant>> updateMerchant(Merchant merchant);
  
  /// Delete a merchant from the system
  Future<Either<Failure, bool>> deleteMerchant(String merchantId);
}
