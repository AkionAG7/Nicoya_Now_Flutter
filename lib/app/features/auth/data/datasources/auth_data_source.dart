import 'package:supabase_flutter/supabase_flutter.dart';


abstract class AuthDataSource {
  Future<Map<String, dynamic>> signIn(String email, String password);
  Future<Map<String, dynamic>> signUp(String email, String password);
  Future<void> signOut();
  Future<Map<String, dynamic>?> getCurrentUser();
  Future<void> updateProfile(String userId, Map<String, dynamic> data);
  Future<void> createAddress(String userId, Map<String, dynamic> data);
}

class SupabaseAuthDataSource implements AuthDataSource {
  final SupabaseClient _supabaseClient;

  SupabaseAuthDataSource(this._supabaseClient);
  @override
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
      if (response.session == null || response.user == null) {
      throw AuthException('No se pudo iniciar sesión');
    }

    final profileResponse = await _supabaseClient
        .from('profile')
        .select()
        .eq('user_id', response.user!.id)
        .single();
        
    // Obtener los roles del usuario desde la nueva estructura
    final userRoles = await _supabaseClient
        .from('user_role')
        .select('role:role_id(slug)')
        .eq('user_id', response.user!.id);
    
    // Crear una lista de roles y generar el string de roles
    final List<String> rolesList = userRoles.map((r) => r['role']['slug'] as String).toList();
    final String role = rolesList.isNotEmpty ? rolesList.join(',') : 'client';
    
    // Verificar si es driver y está verificado
    if (rolesList.contains('driver')) {
      try {
        final driverVerification = await _supabaseClient.from('driver')
            .select('is_verified')
            .eq('driver_id', response.user!.id)
            .single();
            
        if (driverVerification['is_verified'] != true) {
          await _supabaseClient.auth.signOut();
          throw AuthException(
            'Aún no hemos validado tus documentos. Intenta más tarde.');
        }
      } catch (e) {
        await _supabaseClient.auth.signOut();
        if (e is PostgrestException) {
          throw AuthException(
            'Tu cuenta de conductor no está configurada correctamente. Contacta a soporte.');
        }
        rethrow;
      }
    }    return {
      'id': response.user!.id,
      'email': response.user!.email,
      'role': role,
      'phone': profileResponse['phone'],
      'first_name': profileResponse['first_name'],
      'last_name1': profileResponse['last_name1'],
      'last_name2': profileResponse['last_name2'],
      'id_number': profileResponse['id_number'],
      'avatar_url': profileResponse['avatar_url'],
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

    return {
      'id': response.user!.id,
      'email': response.user!.email,
    };
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
      final profileResponse = await _supabaseClient
          .from('profile')
          .select()
          .eq('user_id', currentUser.id)
          .single();

      // Obtener los roles del usuario desde la nueva estructura
      final userRoles = await _supabaseClient
          .from('user_role')
          .select('role:role_id(slug)')
          .eq('user_id', currentUser.id);
      
      // Crear una lista de roles y generar el string de roles
      final List<String> rolesList = userRoles.map((r) => r['role']['slug'] as String).toList();
      final String role = rolesList.isNotEmpty ? rolesList.join(',') : 'client';      return {
        'id': currentUser.id,
        'email': currentUser.email,
        'role': role,
        'phone': profileResponse['phone'],
        'first_name': profileResponse['first_name'],
        'last_name1': profileResponse['last_name1'],
        'last_name2': profileResponse['last_name2'],
        'id_number': profileResponse['id_number'],
        'avatar_url': profileResponse['avatar_url'],
      };
    } catch (e) {
      // Si no hay profile, al menos devolver los datos básicos del usuario
      // pero sin roles (será 'client' por defecto)
      return {
        'id': currentUser.id,
        'email': currentUser.email,
        'role': 'client',
      };
    }
  }

  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await _supabaseClient
        .from('profile')
        .update(data)
        .eq('user_id', userId);
  }

  @override
  Future<void> createAddress(String userId, Map<String, dynamic> data) async {
    await _supabaseClient.from('address').insert({
      'user_id': userId,
      ...data,
    });
  }
}
