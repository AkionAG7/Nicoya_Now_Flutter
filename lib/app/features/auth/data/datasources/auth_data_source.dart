import 'package:supabase_flutter/supabase_flutter.dart';

// Interfaz para la fuente de datos de autenticación
abstract class AuthDataSource {
  Future<Map<String, dynamic>> signIn(String email, String password);
  Future<Map<String, dynamic>> signUp(String email, String password);
  Future<void> signOut();
  Future<Map<String, dynamic>?> getCurrentUser();
  Future<void> updateProfile(String userId, Map<String, dynamic> data);
  Future<void> createAddress(String userId, Map<String, dynamic> data);
}

// Implementación concreta usando Supabase
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

    // Obtiene datos adicionales del perfil
    final profileResponse = await _supabaseClient
        .from('profile')
        .select()
        .eq('user_id', response.user!.id)
        .single();
        
    // Verifica si es conductor y si está verificado
    final String role = profileResponse['role'] ?? 'client';
    if (role == 'driver') {
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
    }

    // Combina datos de autenticación y perfil
    return {
      'id': response.user!.id,
      'email': response.user!.email,
      'role': role,
      ...profileResponse,
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

      return {
        'id': currentUser.id,
        'email': currentUser.email,
        ...profileResponse,
      };
    } catch (e) {
      // Si el perfil no existe, devuelve solo los datos básicos
      return {
        'id': currentUser.id,
        'email': currentUser.email,
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
