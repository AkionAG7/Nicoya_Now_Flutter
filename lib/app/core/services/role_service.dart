import 'package:supabase_flutter/supabase_flutter.dart';

class RoleService {
  final SupabaseClient _supa;
  RoleService(this._supa);

  /* ───────────────────────────── roles ─────────────────────────── */

  /// ¿El usuario actual tiene el rol [slug]?
  Future<bool> hasRole(String slug) async {
    final uid = _supa.auth.currentUser?.id;
    if (uid == null) return false;

    final res = await _supa
        .from('user_role')
        // ① alias «role» enlaza a public.role mediante la FK role_id
        .select('role_id, role:role_id(slug)')
        .eq('user_id', uid)
        .eq('role.slug', slug)          // ② filtra por slug
        .maybeSingle();

    return res != null;
  }  /// Añade el rol sólo si el usuario aún no lo tiene
  Future<void> addRoleIfNotExists(String slug) async {
    final uid = _supa.auth.currentUser?.id;
    if (uid == null) throw Exception('No hay sesión activa');

    // Primero verificar si ya tiene el rol
    final hasRoleAlready = await hasRole(slug);
    if (hasRoleAlready) {
      print('Usuario ya tiene el rol $slug');
      return;
    }

    try {
      // Usar la función RPC de Supabase para agregar el rol
      await _supa.rpc('assign_role_to_user', params: {
        'p_user_id': uid,
        'p_role_slug': slug,
      });
      
      print('Rol $slug agregado exitosamente al usuario $uid usando RPC');
    } catch (e) {
      print('Error usando RPC, intentando inserción directa: $e');
      

      try {
        // Obtener el role_id del slug
        final roleData = await _supa
            .from('role')
            .select('role_id')
            .eq('slug', slug)
            .single();
        
        final roleId = roleData['role_id'] as String;

        // Insertar en user_role usando upsert para evitar duplicados
        await _supa.from('user_role').upsert({
          'user_id': uid,
          'role_id': roleId,
        }, onConflict: 'user_id,role_id');
        
        print('Rol $slug agregado exitosamente al usuario $uid usando inserción directa');
      } catch (directError) {
        print('Error en inserción directa: $directError');
        throw Exception('No se pudo agregar el rol $slug: $directError');
      }
    }
  }

  /// Devuelve todos los roles del usuario actual
  Future<List<Map<String, dynamic>>> getUserRoles() async {
    final uid = _supa.auth.currentUser?.id;
    if (uid == null) return [];

    final data = await _supa
        .from('user_role')
        .select('role_id, role:role_id(slug,label)')
        .eq('user_id', uid);

    return List<Map<String, dynamic>>.from(data);
  }

  /* ─────────────────────── perfil (registro) ────────────────────── */

  /// ¿El usuario ya tiene fila en la tabla profile?
  Future<bool> isUserRegistered() async {
    final uid = _supa.auth.currentUser?.id;
    if (uid == null) return false;

    final profile = await _supa
        .from('profile')
        .select('user_id')
        .eq('user_id', uid)
        .maybeSingle();                 // devuelve null si no existe

    return profile != null;
  }
}
