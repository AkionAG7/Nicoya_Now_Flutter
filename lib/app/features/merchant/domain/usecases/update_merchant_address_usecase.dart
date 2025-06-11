import '../entities/merchant.dart';
import '../repositories/merchant_repository.dart';

class UpdateMerchantAddress {
  final MerchantRepository _repo;
  UpdateMerchantAddress(this._repo);

  /// Actualiza solo la dirección principal y devuelve el Merchant actualizado
  Future<Merchant> call(Merchant merchant) {
    return _repo.updateMerchantAddress(merchant);
  }
}
