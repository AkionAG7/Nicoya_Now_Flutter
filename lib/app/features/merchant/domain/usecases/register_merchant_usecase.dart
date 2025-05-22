import 'package:image_picker/image_picker.dart';
import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
import 'package:nicoya_now/app/features/merchant/domain/repositories/merchant_repository.dart';

class RegisterMerchantUseCase {
  final MerchantRepository repository;

  RegisterMerchantUseCase(this.repository);

  Future<Merchant> execute({
    required String email,
    required String password,
    required String legalId,
    required String businessName,
    required String phone,
    required String address,
    required XFile logo,
  }) {
    return repository.registerMerchant(
      email: email,
      password: password,
      legalId: legalId,
      businessName: businessName,
      phone: phone,
      address: address,
      logo: logo,
    );
  }
}
