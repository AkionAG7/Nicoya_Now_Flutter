import 'package:supabase_flutter/supabase_flutter.dart';

class RoleService {
  final SupabaseClient _supabase;
  RoleService(this._supabase);

  Future<bool> hasRole(String slug) async {
    final res = await _supabase
        .from('user_role')
        .select('role_id')
        .eq('user_id', _supabase.auth.currentUser!.id)
        .eq('role.slug', slug)
        .maybeSingle();
    return res != null;
  }
  
  Future<void> addRoleIfNotExists(String slug) async {
    try {
      // Sólo enviamos el parámetro obligatorio
      await _supabase.rpc(
        'add_role_if_not_exists',
        params: {'_role_slug': slug},
      );
    } on PostgrestException catch (e) {
      throw Exception('Error añadiendo rol: ${e.message}');
    }
  }
  
  Future<void> addRoleWithData(
    String roleSlug, 
    Map<String, dynamic> roleData
  ) async {
    try {
      // First get the current user ID
      final userId = _supabase.auth.currentUser!.id;
      
      // Get the role ID from the slug
      final roleResult = await _supabase
          .from('role')
          .select('id')
          .eq('slug', roleSlug)
          .single();
      
      final roleId = roleResult['id'];
      
      // Check if the user already has this role
      final existingRole = await _supabase
          .from('user_role')
          .select()
          .eq('user_id', userId)
          .eq('role_id', roleId)
          .maybeSingle();
          
      if (existingRole != null) {
        throw Exception('Ya tienes este rol asociado a tu cuenta');
      }
      
      // Insert into user_role table
      await _supabase.from('user_role').insert({
        'user_id': userId,
        'role_id': roleId,
        'is_default': false,
      });
      
      // Update role-specific tables with additional data
      if (roleSlug == 'driver') {
        await _supabase.from('driver').insert({
          'driver_id': userId,
          'id_number': roleData['id_number'],
          'is_verified': false, // New drivers need verification
        });
      } else if (roleSlug == 'merchant') {
        await _supabase.from('merchant').upsert({
          'merchant_id': userId,
          'id_number': roleData['id_number'],
        });
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
      
      if (rolesResult.isEmpty) {
        return ['customer']; // Default role
      }
      
      return rolesResult
          .map<String>((role) => role['role']['slug'] as String)
          .toList();
    } catch (e) {
      return ['customer']; // Default in case of error
    }
  }
  
  Future<void> setDefaultRole(String roleSlug) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      // Get the role ID from the slug
      final roleResult = await _supabase
          .from('role')
          .select('id')
          .eq('slug', roleSlug)
          .single();
      
      final roleId = roleResult['id'];
      
      // First, set all roles to non-default
      await _supabase
          .from('user_role')
          .update({'is_default': false})
          .eq('user_id', userId);
      
      // Then set the selected role as default
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
