import 'package:image_picker/image_picker.dart';
import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';

abstract class MerchantRepository {
  Future<Merchant> registerMerchant({
    required String email,
    required String password,
    required String legalId,
    required String businessName,
    required String phone,
    required String address,
    required XFile logo,
  });
}
