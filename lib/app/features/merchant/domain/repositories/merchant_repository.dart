import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';

abstract class MerchantRepository {
  Future<List<Merchant>> getAllMerchants();
  Future<Merchant> getMerchantByOwner(String ownerId);
  Future<List<Merchant>> getMerchantSearch(String query);
    Future<Merchant> updateMerchantAddress(Merchant merchant);

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
    required AuthController authController,
    String? cedula,
  });
}
