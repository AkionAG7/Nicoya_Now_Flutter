import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/core/utils/role_utils.dart';
import 'package:nicoya_now/app/features/auth/data/datasources/auth_data_source.dart';

class RoleService {
  final SupabaseClient _supabase;
  late final SupabaseAuthDataSource _authDataSource;
  
  RoleService(this._supabase) {
    _authDataSource = SupabaseAuthDataSource(_supabase);
  }
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
  }  Future<void> addRoleWithData(
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

      // Use the existing auth data source method that properly handles:
      // 1. User role insertion
      // 2. Logo upload and storage
      // 3. Address creation 
      // 4. Merchant/driver record creation
      // This ensures consistent behavior between new registrations and role additions
      await _authDataSource.addRoleToUser(userId, roleSlug, roleData);
      
    } on PostgrestException catch (e) {
      throw Exception('Error añadiendo rol: ${e.message}');
    }
  }Future<List<String>> getUserRoles() async {
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
