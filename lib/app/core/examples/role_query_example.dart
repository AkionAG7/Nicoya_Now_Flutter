import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/core/utils/role_utils.dart';

/// Esta clase muestra ejemplos de cómo utilizar las utilidades para consultar roles
/// de manera segura, evitando el uso del campo 'role' que causa problemas
class RoleQueryExamples {
  final SupabaseClient _supabase;

  RoleQueryExamples(this._supabase);

  /// INCORRECTO: Esta manera puede fallar si la columna 'role' no existe
  Future<Map<String, dynamic>?> oldWayGetDriverRole() async {
    try {
      // ⚠️ NO USAR ESTE ENFOQUE - usa 'role' en lugar de 'slug'
      final row = await _supabase
          .from('role')
          .select()
          .eq('role', 'driver')
          .single();
      return row;
    } catch (e) {
      print('Error al consultar rol: $e');
      return null;
    }
  }

  /// CORRECTO: Esta manera es segura usando el campo 'slug'
  Future<Map<String, dynamic>?> newWayGetDriverRole() async {
    try {
      final row = await _supabase
          .from('role')
          .select()
          .eq('slug', 'driver')
          .single();
      return row;
    } catch (e) {
      print('Error al consultar rol: $e');
      return null;
    }
  }

  /// MEJOR AÚN: Usar la utilidad RoleUtils que maneja errores
  Future<Map<String, dynamic>?> bestWayGetDriverRole() async {
    return await RoleUtils.getRoleBySlug(_supabase, 'driver');
  }

  /// Ejemplo de cómo obtener un ID de rol de manera segura
  Future<String?> getDriverRoleId() async {
    return await RoleUtils.getRoleIdBySlug(_supabase, 'driver');
  }

  /// Ejemplo de cómo verificar si un usuario tiene un rol específico
  Future<bool> checkIfUserIsDriver(String userId) async {
    return await RoleUtils.hasRole(_supabase, userId, 'driver');
  }

  /// Ejemplo de cómo obtener todos los roles de un usuario
  Future<List<String>> getUserRoles(String userId) async {
    return await RoleUtils.getRolesForUser(_supabase, userId);
  }
}
