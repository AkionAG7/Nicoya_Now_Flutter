import 'package:nicoya_now/app/features/merchant/data/datasources/merchant_data_source.dart';
import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
import 'package:nicoya_now/app/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';

class MerchantRepositoryImpl implements MerchantRepository {
  final MerchantDataSource _ds;

  MerchantRepositoryImpl(this._ds);

  @override
  Future<List<Merchant>> getMerchantSearch(String query) => _ds.fetchMerchantSearch(query);

  @override
  Future<List<Merchant>> getAllMerchants() => _ds.fetchAllMerchants();

  @override
  Future<Merchant> getMerchantByOwner(String ownerId) => _ds.getMerchantByOwner(ownerId);

    @override
  Future<Merchant> updateMerchantAddress(Merchant merchant) {
    return _ds.updateMerchantAddress(merchant);
  }

  @override
  Future<Merchant> registerMerchant({
    required String address,
    required String businessName,
    required String corporateName,
    required String email,
    required String firstName,
    required String lastName1,
    required String lastName2,
    required String legalId,
    required String logoPath,
    required String password,
    required String phone,
    required AuthController authController,
    String? cedula,
  }) async {    final result = await _ds.registerMerchant(
      address        : address,
      businessName   : businessName,
      corporateName  : corporateName,
      email          : email,
      firstName      : firstName,
      lastName1      : lastName1,
      lastName2      : lastName2,
      legalId        : legalId,
      logoPath       : logoPath,
      password       : password,
      phone          : phone,
      authController : authController,
      cedula         : cedula,
    );

    // Check if should redirect to role selection
    if (result['redirectToRoleSelection'] == true) {
      // For the new flow, we don't return a merchant object
      // We should modify the contract to handle this properly
      // For now, we'll throw an exception with navigation info
      throw Exception('REDIRECT_TO_ROLE_SELECTION:${result['message']}');
    }
    
    // Extract merchant data for traditional flow
    final merchantData = result['merchant'] ?? result;
    return Merchant.fromMap(merchantData);
  }
}
