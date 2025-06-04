import 'package:supabase_flutter/supabase_flutter.dart';

/// Utility class to help handle user roles safely, avoiding SQL errors
class RoleUtils {
  /// Safe function to check if a user has a specific role, handling the case
  /// where the 'role' column might not exist in the database
  static Future<bool> hasRole(SupabaseClient supabase, String userId, String roleSlug) async {
    try {
      // First, get the role_id for the specified slug
      final roleResult = await supabase
          .from('role')
          .select('role_id')
          .eq('slug', roleSlug)
          .maybeSingle();

      if (roleResult == null) {
        // Role doesn't exist in the roles table
        return false;
      }

      final roleId = roleResult['role_id'];

      // Now check if the user has this role by directly querying the join table
      final userRoleResult = await supabase
          .from('user_role')
          .select()
          .eq('user_id', userId)
          .eq('role_id', roleId)
          .maybeSingle();

      return userRoleResult != null;
    } catch (e) {
      //ignore: avoid_print
      print('Error checking role: $e');
      // If there's an error (likely due to missing columns), 
      // return false rather than crashing
      return false;
    }
  }

  /// Safe function to get all roles for a user, handling the case
  /// where the 'role' column might not exist
  static Future<List<String>> getRolesForUser(SupabaseClient supabase, String userId) async {
    try {
      // First, get all role assignments for the user
      final userRoles = await supabase
          .from('user_role')
          .select('role_id')
          .eq('user_id', userId);

      if (userRoles.isEmpty) {
        return [];
      }

      // Extract the role_ids
      final roleIds = userRoles.map((r) => r['role_id'].toString()).toList();
      
      // Get roles one by one to avoid 'in' filter issues
      List<String> roleSlugs = [];
      for (String roleId in roleIds) {
        try {
          final roleResult = await supabase
              .from('role')
              .select('slug')
              .eq('role_id', roleId)
              .maybeSingle();
          
          if (roleResult != null && roleResult['slug'] != null) {
            roleSlugs.add(roleResult['slug']);
          }
        } catch (e) {
          //ignore: avoid_print
          print('Error fetching role $roleId: $e');
        }
      }
      
      return roleSlugs;
    } catch (e) {
      //ignore: avoid_print
      print('Error getting roles: $e');
      // Return empty list instead of crashing
      return [];
    }
  }

  /// Get role info by its slug value (NOT by 'role' column which might cause errors)
  /// This is a safe replacement for queries like:
  /// supabase.from('role').select().eq('role', 'driver').single();
  static Future<Map<String, dynamic>?> getRoleBySlug(
    SupabaseClient supabase, 
    String slug
  ) async {
    try {
      final result = await supabase
          .from('role')
          .select()
          .eq('slug', slug) // Use 'slug' field instead of potentially problematic 'role' field
          .maybeSingle();
      
      return result;
    } catch (e) {
      //ignore: avoid_print
      print('Error getting role by slug: $e');
      return null;
    }
  }
  
  /// Get role ID safely by slug
  static Future<String?> getRoleIdBySlug(
    SupabaseClient supabase, 
    String slug
  ) async {
    try {
      final result = await supabase
          .from('role')
          .select('role_id')
          .eq('slug', slug)
          .maybeSingle();
      
      return result != null ? result['role_id']?.toString() : null;
    } catch (e) {
      //ignore: avoid_print
      print('Error getting role ID by slug: $e');
      return null;
    }
  }
  
  /// Find all roles matching a criteria using a safe approach
  /// This is a safer replacement for queries that filter by column 'role'
  /// 
  /// Example:
  /// Instead of: supabase.from('role').select().eq('role', 'driver')
  /// Use: await RoleUtils.findRoles(supabase, roleType: 'driver')
  static Future<List<Map<String, dynamic>>> findRoles(
    SupabaseClient supabase,
    {String? roleType, bool includeInactive = false}
  ) async {
    try {
      // Iniciar construyendo la consulta paso a paso
      var query = supabase.from('role').select();
      
      // Si se especificó un tipo de rol (slug), filtrar por él
      if (roleType != null && roleType.isNotEmpty) {
        query = query.eq('slug', roleType);
      }
      
      // Si solo queremos roles activos, filtrar por is_active
      if (!includeInactive) {
        query = query.eq('is_active', true);
      }
      
      // Ejecutar la consulta
      final result = await query;
      
      // Convertir a una lista tipada correctamente
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      //ignore: avoid_print
      print('Error buscando roles: $e');
      return [];
    }
  }
  
  /// Gets role information by type (driver, merchant, etc.)
  /// A safer replacement for queries that used eq('role', 'something')
  static Future<Map<String, dynamic>?> getRoleByType(
    SupabaseClient supabase, 
    String roleType
  ) async {
    try {
      final result = await supabase
          .from('role')
          .select()
          .eq('slug', roleType)  // Usar 'slug' en lugar de 'role'
          .maybeSingle();
          
      return result;
    } catch (e) {
      //ignore: avoid_print
      print('Error obteniendo rol por tipo: $e');
      return null;
    }
  }
}
