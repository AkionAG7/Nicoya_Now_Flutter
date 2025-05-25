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
  }

  /// Añade el rol sólo si el usuario aún no lo tiene (RPC en la BD)
  Future<void> addRoleIfNotExists(String slug) async {
    final uid = _supa.auth.currentUser?.id;
    if (uid == null) throw Exception('No hay sesión activa');

    await _supa.rpc(
      'add_role_if_not_exists',
      params: {'_role_slug': slug},
    );
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
