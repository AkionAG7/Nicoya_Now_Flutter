// lib/app/features/merchant/domain/usecases/get_merchant_by_owner_usecase.dart

import '../entities/merchant.dart';
import '../repositories/merchant_repository.dart';

class GetMerchantByOwnerUseCase {
  final MerchantRepository _repo;
  GetMerchantByOwnerUseCase(this._repo);

  Future<Merchant> call(String ownerId) {
    return _repo.getMerchantByOwner(ownerId);
  }
}
