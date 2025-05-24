import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
import 'package:nicoya_now/app/features/merchant/domain/repositories/merchant_repository.dart';

class RegisterMerchantUseCase {
  final MerchantRepository _repository;
  RegisterMerchantUseCase(this._repository);

  Future<Merchant> execute({
    required String email,
    required String password,
    required String legalId,
    required String businessName,
    required String corporateName,
    required String phone,
    required String address,
    required String logoPath,
    required String firstName,
    required String lastName1,
    required String lastName2,
  }) {
    return _repository.registerMerchant(
      email        : email,
      password     : password,
      legalId      : legalId,
      businessName : businessName,
      corporateName: corporateName,
      phone        : phone,
      address      : address,
      logoPath     : logoPath,
      firstName    : firstName,
      lastName1    : lastName1,
      lastName2    : lastName2,
    );
  }
}