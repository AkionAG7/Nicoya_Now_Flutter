import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/core/utils/role_utils.dart';

class RoleService {
  final SupabaseClient _supabase;
  RoleService(this._supabase);
  Future<bool> hasRole(String slug) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      // Use the safer RoleUtils implementation to avoid SQL errors
      return await RoleUtils.hasRole(_supabase, userId, slug);
    } catch (e) {
      //ignore: avoid_print
      print('Error verificando rol: $e');
      return false;
    }
  }
  Future<void> addRoleIfNotExists(String slug) async {
    try {
      //ignore: avoid_print
      print('ROLE SERVICE: Checking if user already has role: $slug');
      final hasIt = await hasRole(slug);
      if (!hasIt) {
        //ignore: avoid_print
        print('ROLE SERVICE: User does not have role $slug, adding it');
        await addRoleWithData(slug, {});
      } else {
        //ignore: avoid_print
        print('ROLE SERVICE: User already has role $slug, skipping');
      }
    } on PostgrestException catch (e) {
      //ignore: avoid_print
      print('ROLE SERVICE: Error adding role: ${e.message}');
      throw Exception('Error añadiendo rol: ${e.message}');
    }
  }

  Future<void> addRoleWithData(
    String roleSlug,
    Map<String, dynamic> roleData,
  ) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      final roleResult = await _supabase
          .from('role')
          .select('role_id')
          .eq('slug', roleSlug)
          .single();

      final roleId = roleResult['role_id'];

      final existingRole = await _supabase
          .from('user_role')
          .select()
          .eq('user_id', userId)
          .eq('role_id', roleId)
          .maybeSingle();

      if (existingRole != null) {
        throw Exception('Ya tienes este rol asociado a tu cuenta');
      }

      await _supabase.from('user_role').insert({
        'user_id': userId,
        'role_id': roleId,
        'is_default': false,
      });      if (roleSlug == 'driver') {
        // Solo actualizamos id_number en profile, no license_number
        // (license_number debe incluirse en los args para DeliverForm2)
        if (roleData['id_number'] != null) {
          await _supabase
              .from('profile')
              .update({'id_number': roleData['id_number']})
              .eq('user_id', userId);      }      } else if (roleSlug == 'merchant') {
        try {
          // Always ensure owner_id is set
          if (!roleData.containsKey('owner_id')) {
            roleData['owner_id'] = userId;
          }
          
          // Verify if a merchant record already exists
          final existingMerchant = await _supabase
              .from('merchant')
              .select()
              .eq('merchant_id', userId)
              .maybeSingle();
              
          if (existingMerchant == null) {
            // If it doesn't exist, use upsert with onConflict to handle potential conflicts
            final merchantData = {
              'merchant_id': userId,
              'owner_id': roleData['owner_id'], // Make sure owner_id is explicitly set
              'legal_id': roleData['id_number'] ?? '',
              'business_name': roleData['business_name'] ?? '',
              'corporate_name': roleData['corporate_name'] ?? '',
              'is_active': false,
              // We don't include main_address_id or logo_url to avoid null constraint errors
            };
            //ignore: avoid_print
            print("Creating new merchant record: $merchantData");
            
            await _supabase.from('merchant').upsert(
              merchantData,
              onConflict: 'merchant_id' // Specify which column to use for resolving conflicts
            );
          } else {
            // If it exists, only update the provided fields
            final updateData = <String, dynamic>{};
            
            // Make sure owner_id is set and included in the update
            updateData['owner_id'] = roleData['owner_id'];
            
            if (roleData['id_number'] != null) updateData['legal_id'] = roleData['id_number'];
            if (roleData['business_name'] != null) updateData['business_name'] = roleData['business_name'];
            if (roleData['corporate_name'] != null) updateData['corporate_name'] = roleData['corporate_name'];
            
            if (updateData.isNotEmpty) {
              //ignore: avoid_print
              print("Updating existing merchant record: $updateData");
              
              await _supabase.from('merchant')
                  .update(updateData)
                  .eq('merchant_id', userId);
            }
          }
        } catch (e) {
          //ignore: avoid_print
          print('Error al actualizar datos de comerciante: $e');
          rethrow;
        }
        
        if (roleData['id_number'] != null) {
          await _supabase
              .from('profile')
              .update({'id_number': roleData['id_number']})
              .eq('user_id', userId);
        }
      }
    } on PostgrestException catch (e) {
      throw Exception('Error añadiendo rol: ${e.message}');
    }
  }  Future<List<String>> getUserRoles() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      // Use the safer RoleUtils approach to get roles
      final roles = await RoleUtils.getRolesForUser(_supabase, userId);
      //ignore: avoid_print
      print('ROLE SERVICE: Returning roles from RoleUtils: $roles');
      return roles;
    } catch (e) {
      //ignore: avoid_print
      print('ROLE SERVICE: Error fetching roles: $e');
      return []; // No asignamos rol por defecto si hay error
    }
  }

  Future<void> setDefaultRole(String roleSlug) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      final roleResult = await _supabase
          .from('role')
          .select('role_id')
          .eq('slug', roleSlug)
          .single();

      final roleId = roleResult['role_id'];

      await _supabase
          .from('user_role')
          .update({'is_default': false})
          .eq('user_id', userId);

      await _supabase
          .from('user_role')
          .update({'is_default': true})
          .eq('user_id', userId)
          .eq('role_id', roleId);
    } on PostgrestException catch (e) {
      throw Exception('Error configurando rol predeterminado: ${e.message}');
    }
  }
}
