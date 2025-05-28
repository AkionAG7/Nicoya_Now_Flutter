import 'package:supabase_flutter/supabase_flutter.dart';

class RoleService {
  final SupabaseClient _supabase;
  RoleService(this._supabase);

  Future<bool> hasRole(String slug) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      final roleResult = await _supabase
          .from('role')
          .select('role_id')
          .eq('slug', slug)
          .single();

      final roleId = roleResult['role_id'];

      final res = await _supabase
          .from('user_role')
          .select('role_id')
          .eq('user_id', userId)
          .eq('role_id', roleId)
          .maybeSingle();

      return res != null;
    } on PostgrestException catch (e) {
      throw Exception('Error verificando rol: ${e.message}');
    }
  }

  Future<void> addRoleIfNotExists(String slug) async {
    try {
      final hasIt = await hasRole(slug);
      if (!hasIt) {
        await addRoleWithData(slug, {});
      }
    } on PostgrestException catch (e) {
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
          // Verificamos si ya existe un comerciante con ese merchant_id para evitar duplicados
          final existingMerchant = await _supabase
              .from('merchant')
              .select()
              .eq('merchant_id', userId)
              .maybeSingle();
              
          if (existingMerchant == null) {
            // Si no existe, usamos upsert con onConflict para manejar posibles conflictos
            await _supabase.from('merchant').upsert(
              {
                'merchant_id': userId,
                'owner_id': userId, 
                'legal_id': roleData['id_number'] ?? '',
                'business_name': roleData['business_name'] ?? '',
                'corporate_name': roleData['corporate_name'] ?? '',
                'is_active': false,
                // Si no tenemos main_address_id o logo_url, simplemente no los incluimos
                // para evitar errores de null en columnas que no lo permiten
              },
              onConflict: 'merchant_id' // Específica qué columna usar para resolver conflictos
            );
          } else {
            // Si existe, solo actualizamos los campos proporcionados
            final updateData = <String, dynamic>{};
            
            if (roleData['id_number'] != null) updateData['legal_id'] = roleData['id_number'];
            if (roleData['business_name'] != null) updateData['business_name'] = roleData['business_name'];
            if (roleData['corporate_name'] != null) updateData['corporate_name'] = roleData['corporate_name'];
            
            if (updateData.isNotEmpty) {
              await _supabase.from('merchant')
                  .update(updateData)
                  .eq('merchant_id', userId);
            }
          }
        } catch (e) {
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
  }

  Future<List<String>> getUserRoles() async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      final rolesResult = await _supabase
          .from('user_role')
          .select('role:role_id(slug)')
          .eq('user_id', userId);

      if (rolesResult.isEmpty) return ['customer'];

      return rolesResult
          .map<String>((role) => role['role']['slug'] as String)
          .toList();
    } catch (e) {
      return ['customer'];
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
