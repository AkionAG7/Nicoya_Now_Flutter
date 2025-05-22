import 'package:image_picker/image_picker.dart';
import 'package:nicoya_now/app/features/merchant/data/datasources/merchant_data_source.dart';
import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
import 'package:nicoya_now/app/features/merchant/domain/repositories/merchant_repository.dart';

class MerchantRepositoryImpl implements MerchantRepository {
  final MerchantDataSource dataSource;

  MerchantRepositoryImpl(this.dataSource);

  @override
  Future<Merchant> registerMerchant({
    required String email,
    required String password,
    required String legalId,
    required String businessName,
    required String phone,
    required String address,
    required XFile logo,
  }) async {
    try {
      final merchantData = await dataSource.registerMerchant(
        email: email,
        password: password,
        legalId: legalId,
        businessName: businessName,
        phone: phone,
        address: address,
        logo: logo,
      );
      
      return Merchant(
        merchantId: merchantData['merchant_id'],
        ownerId: merchantData['owner_id'],
        legalId: merchantData['legal_id'],
        businessName: merchantData['business_name'],
        logoUrl: merchantData['logo_url'],
        mainAddressId: merchantData['main_address_id'],
        isActive: merchantData['is_active'],
      );
    } catch (e) {
      rethrow;
    }
  }
}
