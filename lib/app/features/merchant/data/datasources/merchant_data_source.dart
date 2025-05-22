import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class MerchantDataSource {
  Future<Map<String, dynamic>> registerMerchant({
    required String email,
    required String password,
    required String legalId,
    required String businessName,
    required String phone,
    required String address,
    required XFile logo,
  });
}

class SupabaseMerchantDataSource implements MerchantDataSource {
  final SupabaseClient _supabaseClient;

  SupabaseMerchantDataSource(this._supabaseClient);

  @override
  Future<Map<String, dynamic>> registerMerchant({
    required String email,
    required String password,
    required String legalId,
    required String businessName,
    required String phone,
    required String address,
    required XFile logo,
  }) async {
    // 1. Sign up the user
    final res = await _supabaseClient.auth.signUp(
      email: email.trim(),
      password: password,
    );
    
    if (res.user == null) {
      throw const AuthException('No se pudo crear cuenta');
    }
    
    final uid = res.user!.id;

    try {
      await _supabaseClient.from('profile').update({
        'first_name': businessName.trim(),   
        'role': 'merchant',
      }).eq('user_id', uid);

      final addr = await _supabaseClient
          .from('address')
          .insert({
            'user_id': uid,
            'street': address.trim(),
            'district': '',
          })
          .select('address_id')
          .single();
                                  
      final addressId = addr['address_id'] as String;   

      final ext = logo.name.split('.').last;
      final path = 'merchant/$uid/logo.$ext';

      String publicUrl;
      if (kIsWeb) {
        final bytes = await logo.readAsBytes();
        await _supabaseClient.storage
            .from('merchant-assets')
            .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
      } else {
        await _supabaseClient.storage
            .from('merchant-assets')
            .upload(path, File(logo.path), fileOptions: const FileOptions(upsert: true));
      }
      
      publicUrl = _supabaseClient.storage.from('merchant-assets').getPublicUrl(path);

      await _supabaseClient.from('merchant').insert({
        'merchant_id': uid,           
        'owner_id': uid,
        'legal_id': legalId.trim(),
        'business_name': businessName.trim(),
        'logo_url': publicUrl,
        'main_address_id': addressId,
        'is_active': false,
      });

      return {
        'merchant_id': uid,
        'owner_id': uid,
        'legal_id': legalId.trim(),
        'business_name': businessName.trim(),
        'logo_url': publicUrl,
        'main_address_id': addressId,
        'is_active': false,
      };
    } catch (e) {
      try {
        await _supabaseClient.auth.admin.deleteUser(uid);
      } catch (_) {
      }
      rethrow;
    }
  }
}
