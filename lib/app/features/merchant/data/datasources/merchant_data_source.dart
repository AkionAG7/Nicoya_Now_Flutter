import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class MerchantDataSource {
  Future<Map<String, dynamic>> registerMerchant({
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
  });
}


class SupabaseMerchantDataSource implements MerchantDataSource {
  SupabaseMerchantDataSource(this._supa);
  final SupabaseClient _supa;

  @override
  Future<Map<String, dynamic>> registerMerchant({
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
  }) async {
    // Use AuthController for merchant registration with proper role handling
    final success = await authController.signUpMerchant(
      email: email,
      password: password,
      firstName: firstName,
      lastName1: lastName1,
      lastName2: lastName2,
      phone: phone,
      idNumber: cedula,
    );
    
    if (!success) {
      throw AuthException('No se pudo crear la cuenta de comerciante');
    }
    
    final uid = authController.user!.id;

    try {
      final addr = await _supa.from('address').insert({
        'user_id': uid,
        'street' : address,
        'district': '',
      }).select('address_id').single();
      final addressId = addr['address_id'] as String;

      final ext  = logoPath.split('.').last;
      final path = 'merchant/$uid/logo.$ext';

      if (kIsWeb) {
        final bytes = await File(logoPath).readAsBytes();
        await _supa.storage.from('merchant-assets')
            .uploadBinary(path, bytes,
              fileOptions: const FileOptions(upsert: true));
      } else {
        await _supa.storage.from('merchant-assets')
            .upload(path, File(logoPath),
              fileOptions: const FileOptions(upsert: true));
      }

      final publicUrl =
          _supa.storage.from('merchant-assets').getPublicUrl(path);

      final row = await _supa.from('merchant').insert({
        'merchant_id'    : uid,
        'owner_id'       : uid,
        'legal_id'       : legalId,
        'business_name'  : businessName,
        'corporate_name' : corporateName,
        'logo_url'       : publicUrl,
        'main_address_id': addressId,
        'is_active'      : false,
      }).select().single();                     

      return row;
    } catch (e) {
      // If merchant setup fails, we should handle cleanup appropriately
      // Note: AuthController has already created the user and assigned the role
      rethrow;
    }
  }
}
