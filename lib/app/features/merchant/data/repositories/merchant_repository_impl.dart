import 'package:nicoya_now/app/features/merchant/data/datasources/merchant_data_source.dart';
import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
import 'package:nicoya_now/app/features/merchant/domain/repositories/merchant_repository.dart';

class MerchantRepositoryImpl implements MerchantRepository {
  final MerchantDataSource _ds;

  MerchantRepositoryImpl(this._ds);
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
    String? cedula,
  }) async {
    final m = await _ds.registerMerchant(
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
      cedula         : cedula,
    );

    return Merchant.fromMap(m);   
  }
}
