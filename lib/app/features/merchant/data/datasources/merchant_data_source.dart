import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
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

  Future<List<Merchant>> fetchAllMerchants();
  Future<Merchant> getMerchantByOwner(String ownerId);
  Future<List<Merchant>> fetchMerchantSearch(String query);
  
}

class SupabaseMerchantDataSource implements MerchantDataSource {
  SupabaseMerchantDataSource(this._supa);
  final SupabaseClient _supa;

  @override
  Future<List<Merchant>> fetchMerchantSearch(String query) async {
    final response = await _supa
        .from('merchant')
        .select()
        .or('business_name.ilike.%$query%,corporate_name.ilike.%$query%');

    if (response is List) {
      return response.map((item) {
        return Merchant(
          merchantId: item['merchant_id'] as String,
          ownerId: item['owner_id'] as String,
          legalId: item['legal_id'] as String,
          businessName: item['business_name'] as String,
          corporateName: item['corporate_name'] as String?,
          logoUrl: item['logo_url'] as String? ?? '',
          mainAddressId: item['main_address_id'] as String,
          isActive: item['is_active'] as bool? ?? false,
          createdAt: DateTime.parse(item['created_at'] as String),
        );
      }).toList();
    } else {
      throw Exception('La respuesta no es una lista');
    }
  }

  @override
  Future<Merchant> getMerchantByOwner(String ownerId) async {
    final resp =
        await _supa
            .from('merchant')
            .select(
              'merchant_id, owner_id, legal_id, business_name, corporate_name, main_address_id, logo_url, is_active, created_at',
            )
            .eq('owner_id', ownerId)
            .maybeSingle();

    if (resp == null) throw Exception('Comercio no encontrado');

    return Merchant(
      merchantId: resp['merchant_id'],
      ownerId: resp['owner_id'],
      legalId: resp['legal_id'],
      businessName: resp['business_name'],
      corporateName: resp['corporate_name'],
      mainAddressId: resp['main_address_id'],
      logoUrl: resp['logo_url'] ?? '',
      isActive: resp['is_active'] ?? false,
      createdAt: DateTime.parse(resp['created_at'] as String),
    );
  }

  @override
  Future<List<Merchant>> fetchAllMerchants() async {
    try {
      final response = await _supa.from('merchant').select();
      if (response is List) {
        return response.map((item) {
          return Merchant(
            merchantId: item['merchant_id'] as String,
            ownerId: item['owner_id'] as String,
            legalId: item['legal_id'] as String,
            businessName: item['business_name'] as String,
            corporateName: item['corporate_name'] as String?,
            logoUrl: item['logo_url'] as String? ?? '',
            mainAddressId: item['main_address_id'] as String,
            isActive: item['is_active'] as bool? ?? false,
            createdAt: DateTime.parse(item['created_at'] as String),
          );
        }).toList();
      } else {
        throw Exception('La respuesta no es una lista');
      }
    } catch (e) {
      throw Exception('Error al obtener los comerciantes: $e');
    }
  }

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
    String? cedula,  }) async {
    // Primero creamos el usuario con su rol de merchant
    final success = await authController.signUpMerchant(
      email: email,
      password: password,
      firstName: firstName,
      lastName1: lastName1,
      lastName2: lastName2,
      phone: phone,
      idNumber: cedula,
      businessName: businessName,  // Ahora pasamos explícitamente el nombre del negocio
      corporateName: corporateName,  // Y el nombre corporativo
    );

    if (!success) {
      throw AuthException('No se pudo crear la cuenta de comerciante');
    }

    final uid = authController.user!.id;
      try {      // Check if a merchant record already exists
      final existingMerchant = await _supa
          .from('merchant')
          .select()
          .eq('merchant_id', uid)
          .maybeSingle();
          
      if (existingMerchant != null) {
        // If it exists, update the data and continue with the process
        await _supa.from('merchant')
          .update({
            'legal_id': legalId,
            'business_name': businessName,
            'corporate_name': corporateName,
            'owner_id': uid, // Ensure owner_id is always set
          })
          .eq('merchant_id', uid);
      }
      
      // Create address record with proper error handling
      String addressId;
      try {
        final addr = await _supa
            .from('address')
            .insert({
              'user_id': uid, 
              'street': address, 
              'district': ''
            })
            .select('address_id')
            .single();
        addressId = addr['address_id'] as String;
        print("Created address with ID: $addressId");
      } catch (e) {
        print("Error creating address: $e");
        // Create a default address in case of failure
        final defaultAddr = await _supa
            .from('address')
            .insert({
              'user_id': uid, 
              'street': 'Dirección pendiente', 
              'district': ''
            })
            .select('address_id')
            .single();
        addressId = defaultAddr['address_id'] as String;
      }

      final ext = logoPath.split('.').last;
      final path = 'merchant/$uid/logo.$ext';

      if (kIsWeb) {
        final bytes = await File(logoPath).readAsBytes();
        await _supa.storage
            .from('merchant-assets')
            .uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );
      } else {
        await _supa.storage
            .from('merchant-assets')
            .upload(
              path,
              File(logoPath),
              fileOptions: const FileOptions(upsert: true),
            );
      }      final publicUrl = _supa.storage
          .from('merchant-assets')
          .getPublicUrl(path);      // If we already verified that it exists, update the missing info
      if (existingMerchant != null) {
        print("Updating existing merchant with logo and address");
        final row = await _supa
              .from('merchant')
              .update({
                'logo_url': publicUrl,
                'main_address_id': addressId,
                'owner_id': uid, // Ensure owner_id is always set
              })
              .eq('merchant_id', uid)
              .select()
              .single();
        return row;
      } else {      // If it doesn't exist, insert it completely
        print("Creating new merchant record with all details");
        final row = await _supa
              .from('merchant')
              .upsert(
                {  // Use upsert to avoid duplicate key errors
                  'merchant_id': uid,
                  'owner_id': uid, // Ensure owner_id is explicitly set
                  'legal_id': legalId,
                  'business_name': businessName,
                  'corporate_name': corporateName,
                  'logo_url': publicUrl,
                  'main_address_id': addressId,
                  'is_active': false,
                },
                onConflict: 'merchant_id' // Especificar la columna para resolver conflictos
              )
              .select()
              .single();
        return row;
      }

    } catch (e) {
      // If merchant setup fails, we should handle cleanup appropriately
      // Note: AuthController has already created the user and assigned the role
      rethrow;
    }
  }
}
