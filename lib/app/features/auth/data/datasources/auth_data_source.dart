import 'package:supabase_flutter/supabase_flutter.dart';


abstract class AuthDataSource {
  Future<Map<String, dynamic>> signIn(String email, String password);
  Future<Map<String, dynamic>> signUp(String email, String password);
  Future<void> signOut();
  Future<Map<String, dynamic>?> getCurrentUser();
  Future<void> updateProfile(String userId, Map<String, dynamic> data);
  Future<void> createAddress(String userId, Map<String, dynamic> data);
  Future<List<String>> getRolesForUser(String userId);
  Future<void> addRoleToUser(String userId, String roleId, Map<String, dynamic> roleData);
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

  @override  Future<void> createAddress(String userId, Map<String, dynamic> data) async {
    await _supabaseClient.from('address').insert({
      'user_id': userId,
      ...data,
    });
  }
  
  @override
  Future<List<String>> getRolesForUser(String userId) async {
    final roles = await _supabaseClient
        .from('user_role')
        .select('role:role_id(slug)')
        .eq('user_id', userId);
    
    if (roles.isEmpty) {
      return ['customer']; // Default role if no roles are found
    }
    
    return roles.map<String>((role) => role['role']['slug'] as String).toList();
  }

  @override
  Future<void> addRoleToUser(String userId, String roleSlug, Map<String, dynamic> roleData) async {    // First get the role_id from the role slug
    final roleResult = await _supabaseClient
        .from('role')
        .select('role_id')
        .eq('slug', roleSlug)
        .single();
    
    final roleId = roleResult['role_id'];
    
    // Insert into the user_role table
    await _supabaseClient.from('user_role').insert({
      'user_id': userId,
      'role_id': roleId,
      'is_default': false, // Not setting as default unless specified
    });      // If additional role data is provided, store it based on role type
    if (roleData.isNotEmpty) {
      // Handle id_number in the profile table for all roles
      if (roleData['id_number'] != null) {
        await _supabaseClient
            .from('profile')
            .update({'id_number': roleData['id_number']})
            .eq('user_id', userId);
      }
      
      // Para el rol de driver, NO creamos el registro en la tabla driver aquí
      // Se creará cuando se complete el segundo formulario con vehicle_type
      if (roleSlug == 'merchant') {
        await _supabaseClient.from('merchant').upsert({
          'merchant_id': userId,
        });
      }
        // Update the profile with any remaining role data
      final profileData = Map<String, dynamic>.from(roleData);
      profileData.remove('id_number'); // Already handled above
      profileData.remove('license_number'); // license_number solo pertenece a la tabla driver
      
      if (profileData.isNotEmpty) {
        await _supabaseClient
            .from('profile')
            .update(profileData)
            .eq('user_id', userId);
      }
    }
  }
}
