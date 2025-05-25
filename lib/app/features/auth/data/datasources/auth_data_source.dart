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
    }    final profileResponse = await _supabaseClient
        .from('profile')
        .select()
        .eq('user_id', response.user!.id)
        .single();
        
    // Obtener roles desde la tabla user_role en lugar de profile.role
    final roles = await _supabaseClient
        .from('user_role')
        .select('role:role_id(slug)')
        .eq('user_id', response.user!.id);

    final primaryRole = roles.isNotEmpty ? roles.first['role']['slug'] : 'customer';
    
    if (primaryRole == 'driver') {
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
    return {
      'id': response.user!.id,
      'email': response.user!.email,
      'role': primaryRole,
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
    }    try {
      final profileResponse = await _supabaseClient
          .from('profile')
          .select()
          .eq('user_id', currentUser.id)
          .single();

      // Obtener roles desde la tabla user_role
      final roles = await _supabaseClient
          .from('user_role')
          .select('role:role_id(slug)')
          .eq('user_id', currentUser.id);

      final primaryRole = roles.isNotEmpty ? roles.first['role']['slug'] : 'customer';

      return {
        'id': currentUser.id,
        'email': currentUser.email,
        'role': primaryRole,
        ...profileResponse,
      };    } catch (e) {
      return {
        'id': currentUser.id,
        'email': currentUser.email,
        'role': 'customer', // Default role if profile/roles can't be fetched
      };
    }
  }
  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    // Crear una copia de los datos sin la columna 'role'
    final profileData = Map<String, dynamic>.from(data);
    profileData.remove('role');
    
    await _supabaseClient
        .from('profile')
        .update(profileData)
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
