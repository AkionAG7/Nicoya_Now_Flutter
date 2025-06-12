import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:nicoya_now/app/features/address/domain/entities/address.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthDataSource {
  Future<Map<String, dynamic>> signIn(String email, String password, {bool ignoreDriverVerification = false});
  Future<Map<String, dynamic>> signUp(String email, String password);
  Future<void> signOut();
  Future<Map<String, dynamic>?> getCurrentUser();
  Future<void> updateProfile(String userId, Map<String, dynamic> data);
  Future<void> createAddress(String userId, Map<String, dynamic> data);
  Future<List<String>> getRolesForUser(String userId);
  Future<void> addRoleToUser(
    String userId,
    String roleId,
    Map<String, dynamic> roleData,
  );
  // Nuevos métodos para verificar el estado de merchant y driver
  Future<bool> getMerchantVerificationStatus(String userId);
  Future<bool> getDriverVerificationStatus(String userId);
  Future<void> updateUserInfo({
    required String userId,
    required String phone,
    required String address,
    String? district,
  });

  Future<List<Address>> getUserAddress(String userID);
}

class SupabaseAuthDataSource implements AuthDataSource {
  final SupabaseClient _supabaseClient;

  SupabaseAuthDataSource(this._supabaseClient);  @override
  Future<Map<String, dynamic>> signIn(String email, String password, {bool ignoreDriverVerification = false}) async {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session == null || response.user == null) {
      throw AuthException('No se pudo iniciar sesión');
    }
    final profileResponse =
        await _supabaseClient
            .from('profile')
            .select()
            .eq('user_id', response.user!.id)
            .single();
    // Obtener roles desde la tabla user_role en lugar de profile.role
    final roles = await _supabaseClient
        .from('user_role')
        .select('role_id, role:role_id(slug)')
        .eq('user_id', response.user!.id);

    // Usamos exactamente los roles asignados, sin defaults
    String primaryRole = '';
    if (roles.isNotEmpty && roles.first['role'] != null) {
      primaryRole = roles.first['role']['slug'] ?? '';
    }

    if (primaryRole == 'driver' && !ignoreDriverVerification) {
      try {
        final driverVerification =
            await _supabaseClient
                .from('driver')
                .select('is_verified')
                .eq('driver_id', response.user!.id)
                .single();

        if (driverVerification['is_verified'] != true) {
          await _supabaseClient.auth.signOut();
          throw AuthException(
            'Aún no hemos validado tus documentos. Intenta más tarde.',
          );
        }
      } catch (e) {
        await _supabaseClient.auth.signOut();
        if (e is PostgrestException) {
          throw AuthException(
            'Tu cuenta de conductor no está configurada correctamente. Contacta a soporte.',
          );
        }
        rethrow;
      }
    }
    return {
      'id': response.user!.id,
      'email': response.user!.email,
      'role': primaryRole,
      ...profileResponse,
    };
  }

  @override
  Future<Map<String, dynamic>> signUp(String email, String password) async {
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw AuthException('No se pudo crear la cuenta');
    }

    // Espera breve para asegurarse de que el usuario esté disponible
    await Future.delayed(Duration(seconds: 1));

    // Validar que el usuario esté realmente autenticado
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw AuthException('Usuario no autenticado aún después del registro');
    }

    return {'id': userId, 'email': response.user!.email};
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final currentUser = _supabaseClient.auth.currentUser;

    if (currentUser == null) {
      return null;
    }
    try {
      final profileResponse =
          await _supabaseClient
              .from('profile')
              .select()
              .eq('user_id', currentUser.id)
              .single(); // Obtener roles desde la tabla user_role
      final roles = await _supabaseClient
          .from('user_role')
          .select('role_id, role:role_id(slug)')
          .eq('user_id', currentUser.id);

      // Solo usamos el rol que realmente tenga asignado, sin defaults
      String primaryRole = '';
      if (roles.isNotEmpty && roles.first['role'] != null) {
        primaryRole = roles.first['role']['slug'] ?? '';
      }

      return {
        'id': currentUser.id,
        'email': currentUser.email,
        'role': primaryRole,
        ...profileResponse,
      };
    } catch (e) {
      return {
        'id': currentUser.id,
        'email': currentUser.email,
        'role': '', // No asignamos ningún rol por defecto
      };
    }
  }

  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    // Crear una copia de los datos sin la columna 'role'
    final profileData = Map<String, dynamic>.from(data);
    profileData.remove('role');

    await _supabaseClient
        .from('profile')
        .update(profileData)
        .eq('user_id', userId);
  }

  @override
  Future<void> createAddress(String userId, Map<String, dynamic> data) async {
    await _supabaseClient.from('address').insert({'user_id': userId, ...data});
  }

  @override
  Future<List<String>> getRolesForUser(String userId) async {
    // Use a simpler role querying approach to avoid SQL errors with 'role' column
    try {
      // First, get user-role associations
      final userRoles = await _supabaseClient
          .from('user_role')
          .select('role_id')
          .eq('user_id', userId);

      if (userRoles.isEmpty) {
        return [];
      }

      // Extract role IDs
      final List<String> roleIds =
          userRoles
              .map<String>((role) => role['role_id'].toString())
              .toList(); // Get role details
      final roles = await _supabaseClient
          .from('role')
          .select('slug')
          .filter('role_id', 'in', roleIds);

      // Return role slugs
      return roles
          .map<String>((role) => role['slug'].toString())
          .where((slug) => slug.isNotEmpty)
          .toList();
    } catch (e) {
      //ignore: avoid_print
      print('Error fetching roles: $e');
      return []; // Return empty list on error
    }
  }

  @override
  Future<void> addRoleToUser(
    String userId,
    String roleSlug,
    Map<String, dynamic> roleData,
  ) async {
    // First get the role_id from the role slug
    final roleResult =
        await _supabaseClient
            .from('role')
            .select('role_id')
            .eq('slug', roleSlug)
            .single();    final roleId = roleResult['role_id'];

    // First, deactivate all existing roles for this user
    await _supabaseClient.from('user_role')
        .update({'is_default': false})
        .eq('user_id', userId);

    // Insert into the user_role table with the new role as default (active)
    await _supabaseClient.from('user_role').insert({
      'user_id': userId,
      'role_id': roleId,
      'is_default': true, // New role becomes immediately active
    });// If additional role data is provided, store it based on role type
    if (roleData.isNotEmpty) {
      // Handle id_number in the profile table for all roles
      if (roleData['id_number'] != null) {
        await _supabaseClient
            .from('profile')
            .update({'id_number': roleData['id_number']})
            .eq('user_id', userId);
      }

      // Para el rol de driver, NO creamos el registro en la tabla driver aquí
      // Se creará cuando se complete el segundo formulario con vehicle_type      if (roleSlug == 'merchant') {      // Always ensure both merchant_id and owner_id are set to prevent not-null constraint violations
      final merchantData = {
        'merchant_id': userId,
        'owner_id':
            userId, // Set owner_id to prevent not-null constraint violation
        'is_active': false, // ¡No activar aquí! Lo hace el admin desde el dashboard.
      };

      // Add additional merchant-specific fields if available
      if (roleData['business_name'] != null)
        merchantData['business_name'] = roleData['business_name'];
      if (roleData['corporate_name'] != null)
        merchantData['corporate_name'] = roleData['corporate_name'];
      if (roleData['id_number'] != null)
        merchantData['legal_id'] = roleData['id_number'];

      await _supabaseClient
          .from('merchant')
          .upsert(merchantData, onConflict: 'merchant_id');
    } // Handle address data if provided
    if (roleData['address'] != null &&
        roleData['address'].toString().trim().isNotEmpty) {
      try {
        // Create a new address entry with more error checking
        final addrResult =
            await _supabaseClient
                .from('address')
                .insert({
                  'user_id': userId,
                  'street': roleData['address'],
                  'district':
                      roleData['district'] ?? '', // Default empty district
                })
                .select('address_id')
                .single(); // Use single instead of maybeSingle to ensure we get a result

        if (roleSlug == 'merchant') {
          final addressId = addrResult['address_id'] as String;
          // Update merchant with the address ID - with error handling
          await _supabaseClient
              .from('merchant')
              .update({'main_address_id': addressId})
              .eq('merchant_id', userId);
        }
      } catch (e) {
        //ignore: avoid_print
        print("Error creating address: $e");
        // We should not throw here, but continue the process even if address creation fails
        // This avoids breaking the entire role addition flow
      }
    }
    // Handle logo if provided for merchants
    if (roleSlug == 'merchant' && roleData['logoPath'] != null) {
      try {
        final logoPath = roleData['logoPath'].toString();
        final ext = logoPath.split('.').last;
        final path = 'merchant/$userId/logo.$ext';

        // Check if bucket exists first to avoid errors
        try {
          // Ensure the bucket exists or create it
          final buckets = await _supabaseClient.storage.listBuckets();
          bool bucketExists = buckets.any(
            (bucket) => bucket.name == 'merchant-assets',
          );

          if (!bucketExists) {
            //ignore: avoid_print
            print("Merchant assets bucket does not exist, creating...");
            try {
              await _supabaseClient.storage.createBucket(
                'merchant-assets',
                const BucketOptions(public: true),
              );
            } catch (bucketError) {
              // Bucket might have been created by another process
              //ignore: avoid_print
              print("Error creating bucket: $bucketError");
            }
          }

          // Upload file based on platform
          if (kIsWeb) {
            final bytes = await File(logoPath).readAsBytes();
            await _supabaseClient.storage
                .from('merchant-assets')
                .uploadBinary(
                  path,
                  bytes,
                  fileOptions: const FileOptions(upsert: true),
                );
          } else {
            await _supabaseClient.storage
                .from('merchant-assets')
                .upload(
                  path,
                  File(logoPath),
                  fileOptions: const FileOptions(upsert: true),
                );
          }

          // Get the public URL
          final publicUrl = _supabaseClient.storage
              .from('merchant-assets')
              .getPublicUrl(path);

          // Update the merchant with the logo URL
          await _supabaseClient
              .from('merchant')
              .update({'logo_url': publicUrl})
              .eq('merchant_id', userId);
        } catch (storageError) {
          //ignore: avoid_print
          print("Storage operation failed: $storageError");
        }
      } catch (e) {
        //ignore: avoid_print
        print("Error in logo upload process: $e");
        // Continue with the process even if logo upload fails
      }
    }

    // Update the profile with any remaining role data
    final profileData = Map<String, dynamic>.from(roleData);
    profileData.remove('id_number'); // Already handled above
    profileData.remove(
      'license_number',
    ); // license_number solo pertenece a la tabla driver
    profileData.remove('address'); // Address is handled separately above
    profileData.remove('logoPath'); // Logo is handled separ
  }

  @override
  Future<bool> getMerchantVerificationStatus(String userId) async {
    try {
      final result =
          await _supabaseClient
              .from('merchant')
              .select('is_active')
              .eq('merchant_id', userId)
              .single();

      return result['is_active'] as bool? ?? false;
    } catch (e) {
      //ignore: avoid_print
      print("Error checking merchant verification status: $e");
      return false; // En caso de error, asumimos que no está verificado
    }
  }

  @override
  Future<bool> getDriverVerificationStatus(String userId) async {
    try {
      final result =
          await _supabaseClient
              .from('driver')
              .select('is_verified')
              .eq('driver_id', userId)
              .single();

      return result['is_verified'] as bool? ?? false;
    } catch (e) {
      //ignore: avoid_print
      print("Error checking driver verification status: $e");
      return false; // En caso de error, asumimos que no está verificado
    }
  }

  @override
  Future<void> updateUserInfo({
    required String userId,
    required String phone,
    required String address,
    String? district,
  }) async {
    try {
      final existingNumber =
          await _supabaseClient
              .from('profile')
              .select('phone')
              .eq('user_id', userId)
              .single();

      if (phone.isNotEmpty && existingNumber['phone'] != phone) {
        await _supabaseClient
            .from('profile')
            .update({'phone': phone})
            .eq('user_id', userId);
      } else {}
      final existingAddress = await _supabaseClient
          .from('address')
          .select('address_id')
          .eq('user_id', userId);

      if (existingAddress.isNotEmpty) {
        await _supabaseClient
            .from('address')
            .update({'street': address, 'district': district ?? ''})
            .eq('address_id', existingAddress[0]['address_id']);
      } else {
        await _supabaseClient.from('address').insert({
          'user_id': userId,
          'street': address,
          'district': district ?? '',
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error updating user info: $e");
      throw Exception("No se pudo actualizar la información del usuario");
    }
  }

  @override
  Future<List<Address>> getUserAddress(String userID) async {
    try {
      final response = await _supabaseClient
          .from('address')
          .select(
            'address_id, user_id, street, district, lat, lng, note, created_at',
          )
          .eq('user_id', userID);

      if (response.isEmpty) {
        return [];
      }

      return response
          .map<Address>(
            (item) => Address(
              address_id: item['address_id'] as String,
              user_id: item['user_id'] as String,
              lat: (item['lat'] as num?)?.toDouble() ?? 0.0,
              lng: (item['lng'] as num?)?.toDouble() ?? 0.0,
              street: item['street'] as String,
              district: item['district'] as String,
              note: item['note'] as String? ?? '',
              created_at: DateTime.parse(item['created_at'] as String),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception("No se pudo obtener la dirección del usuario");
    }
  }
}
