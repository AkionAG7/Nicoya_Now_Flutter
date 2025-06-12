import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:nicoya_now/app/features/merchant/domain/entities/address.dart';
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
    Future<Merchant> updateMerchantAddress(Merchant merchant);
}

class SupabaseMerchantDataSource implements MerchantDataSource {
  SupabaseMerchantDataSource(this._supa);
  final SupabaseClient _supa;
  @override
  Future<List<Merchant>> fetchMerchantSearch(String query) async {
    final response = await _supa
        .from('merchant')
        .select()
        .eq('is_active', true) // Solo comerciantes activos
        .or('business_name.ilike.%$query%,corporate_name.ilike.%$query%');

    return response.map<Merchant>((item) {
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
        mainAddress: Address.empty(),
      );
    }).toList();
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
      createdAt: DateTime.parse(resp['created_at'] as String), mainAddress: Address.empty(),
    );
  }
  @override
  Future<List<Merchant>> fetchAllMerchants() async {
    try {
      final response = await _supa
          .from('merchant')
          .select()
          .eq('is_active', true); // Solo comerciantes activos
      
      return response.map<Merchant>((item) {
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
          mainAddress: Address.empty(),
        );
      }).toList();
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
    String? cedula,
  }) async {
    //ignore: avoid_print
    print('MERCHANT REGISTER: Starting merchant registration process');    // Primero creamos el usuario con su rol de merchant
    final result = await authController.signUpMerchant(
      email: email,
      password: password,
      firstName: firstName,
      lastName1: lastName1,
      lastName2: lastName2,
      phone: phone,
      idNumber: cedula,
      businessName:
          businessName, // Ahora pasamos explícitamente el nombre del negocio
      corporateName: corporateName, // Y el nombre corporativo
      isNewUserRegistration: true, // Indicate this is a new user registration flow
    );

    final success = result['success'] ?? false;
    
    if (!success) {
      //ignore: avoid_print
      print('MERCHANT REGISTER: Failed to create merchant account');
      throw AuthException(result['message'] ?? 'No se pudo crear la cuenta de comerciante');
    }
    
    // Check if should redirect to role selection page
    if (result['redirectToRoleSelection'] == true) {
      //ignore: avoid_print
      print('MERCHANT REGISTER: Merchant registration complete, should redirect to role selection');
      // Return immediately with navigation instructions
      return {
        'success': true,
        'redirectToRoleSelection': true,
        'message': result['message'] ?? 'Registro exitoso'
      };
    }
    
    //ignore: avoid_print
    print('MERCHANT REGISTER: Successfully created merchant account and role');

    final uid = authController.user!.id;
    try {
      // Check if a merchant record already exists
      final existingMerchant =
          await _supa
              .from('merchant')
              .select()
              .eq('merchant_id', uid)
              .maybeSingle();

      if (existingMerchant != null) {
        // If it exists, update the data and continue with the process
        await _supa
            .from('merchant')
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
        final addr =
            await _supa
                .from('address')
                .insert({'user_id': uid, 'street': address, 'district': ''})
                .select('address_id')
                .single();
        addressId = addr['address_id'] as String;
        //ignore: avoid_print
        print("Created address with ID: $addressId");
      } catch (e) {
        //ignore: avoid_print
        print("Error creating address: $e");
        // Create a default address in case of failure
        final defaultAddr =
            await _supa
                .from('address')
                .insert({
                  'user_id': uid,
                  'street': 'Dirección pendiente',
                  'district': '',
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
      }
      final publicUrl = _supa.storage
          .from('merchant-assets')
          .getPublicUrl(
            path,
          ); // If we already verified that it exists, update the missing info
      if (existingMerchant != null) {
        //ignore: avoid_print
        print("Updating existing merchant with logo and address");
        final row =
            await _supa
                .from('merchant')                .update({
                  'logo_url': publicUrl,
                  'main_address_id': addressId,
                  'owner_id': uid, // Ensure owner_id is always set
                })
                .eq('merchant_id', uid)
                .select()
                .single();
        return {
          'success': true,
          'merchant': row,
          'message': 'Registro de comerciante exitoso'
        };
      } else {
        // If it doesn't exist, insert it completely
        //ignore: avoid_print
        print("Creating new merchant record with all details");
        final row =
            await _supa
                .from('merchant')
                .upsert(                  {
                    // Use upsert to avoid duplicate key errors
                    'merchant_id': uid,
                    'owner_id': uid, // Ensure owner_id is explicitly set
                    'legal_id': legalId,
                    'business_name': businessName,
                    'corporate_name': corporateName,
                    'logo_url': publicUrl,
                    'main_address_id': addressId,
                    'is_active': false, // ¡No activar aquí! Lo hace el admin desde el dashboard.
                  },
                  onConflict:
                      'merchant_id', // Especificar la columna para resolver conflictos
                )
                .select()
                .single();
        return {
          'success': true,
          'merchant': row,
          'message': 'Registro de comerciante exitoso'
        };
      }
    } catch (e) {
      // If merchant setup fails, we should handle cleanup appropriately
      // Note: AuthController has already created the user and assigned the role
      rethrow;
    }
  }

   @override
  Future<Merchant> updateMerchantAddress(Merchant merchant) async {
    // 1) Actualizamos la fila en la tabla `address`
    final addressJson = await _supa
      .from('address')
      .update({
        'street'   : merchant.mainAddress.street,
        'district' : merchant.mainAddress.district,
        'lat'      : merchant.mainAddress.lat,
        'lng'      : merchant.mainAddress.lng,
        'note'     : merchant.mainAddress.note,
      })
      .eq('address_id', merchant.mainAddress.addressId)
      .select()
      .single();

    // 2) Parseamos la respuesta a nuestra entidad Address
    final updatedAddress = Address.fromMap(addressJson);

    // 3) Retornamos un nuevo Merchant con la dirección actualizada en memoria
    return merchant.copyWith(mainAddress: updatedAddress);
  }
}
