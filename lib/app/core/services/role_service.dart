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
}
