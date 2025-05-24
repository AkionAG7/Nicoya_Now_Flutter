import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';

abstract class MerchantRepository {
  Future<Merchant> registerMerchant({
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
  });
}
