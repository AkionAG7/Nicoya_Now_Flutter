import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    String? cedula,
  }) async {
    final auth = await _supa.auth.signUp(email: email, password: password);
    if (auth.user == null) throw const AuthException('No se pudo crear cuenta');
    final uid = auth.user!.id;

    try {     
      final Map<String, dynamic> profileData = {
        'first_name' : firstName,
        'last_name1' : lastName1,
        'last_name2' : lastName2,
        'phone'      : phone,
        'role'       : 'merchant',
      };
      
      if (cedula != null && cedula.isNotEmpty) {
        profileData['id_number'] = cedula;
      }
      
      await _supa.from('profile').update(profileData).eq('user_id', uid);

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
      try { await _supa.auth.admin.deleteUser(uid); } catch (_) {}
      rethrow;
    }
  }
}
