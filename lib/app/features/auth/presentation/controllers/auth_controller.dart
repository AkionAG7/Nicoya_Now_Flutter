import 'package:flutter/material.dart';
import 'package:nicoya_now/app/core/services/role_service.dart';
import 'package:nicoya_now/app/features/auth/domain/entities/user.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/sign_up_usecase.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthController extends ChangeNotifier {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final RoleService _roleService;

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  List<Map<String, dynamic>>? _userRoles;

  AuthController({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required RoleService roleService,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _roleService = roleService;
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>>? get userRoles => _userRoles;

  // Getter para debugging
  bool get hasActiveSession => _user != null && _state == AuthState.authenticated;

  // Obtener los roles del usuario desde Supabase
  Future<void> loadUserRoles() async {
    try {
      _userRoles = await _roleService.getUserRoles();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Verificar si el usuario ya está registrado
  Future<bool> isUserRegistered() async {
    return await _roleService.isUserRegistered();
  }

  // Verificar si el usuario tiene un rol específico
  Future<bool> hasRole(String slug) async {
    return await _roleService.hasRole(slug);
  }  // Agregar un nuevo rol al usuario
  Future<void> addRole(String slug) async {
    print('🔍 [AuthController.addRole] Usuario en sesión: ${_user?.id ?? "null"}');
    print('🔍 [AuthController.addRole] Email del usuario: ${_user?.email ?? "null"}');
    
    if (_user == null) {
      print('❌ [AuthController.addRole] ERROR: No hay usuario en sesión');
      throw Exception('No hay usuario en sesión');
    }
    
    await _roleService.addRoleIfNotExists(slug);
    await loadUserRoles(); // Recargar los roles después de agregar uno nuevo
    print('✅ [AuthController.addRole] Rol $slug agregado exitosamente');
  }  // Método especializado para agregar rol después de login exitoso
  Future<bool> addRoleToExistingUser(String email, String password, String roleSlug) async {
    print('🔄 [AuthController.addRoleToExistingUser] Iniciando login para agregar rol $roleSlug');
    try {
      // Primero hacer login
      final loginSuccess = await signIn(email, password);
      if (!loginSuccess) {
        print('❌ [AuthController.addRoleToExistingUser] Login falló');
        return false;
      }

      print('✅ [AuthController.addRoleToExistingUser] Login exitoso');
      print('🔍 [AuthController.addRoleToExistingUser] Usuario después del login: ${_user?.id ?? "null"}');
      print('🔍 [AuthController.addRoleToExistingUser] Estado: $_state');

      // Verificar si ya tiene este rol
      final alreadyHasRole = await hasRole(roleSlug);
      
      if (alreadyHasRole) {
        // El usuario ya tiene el rol - esto es OK, no es un error
        print('ℹ️ [AuthController.addRoleToExistingUser] El usuario ya tiene el rol $roleSlug');
        return true;
      }
      
      // Agregar el rol si no lo tiene
      print('🔄 [AuthController.addRoleToExistingUser] Agregando rol $roleSlug...');
      await addRole(roleSlug);
      print('✅ [AuthController.addRoleToExistingUser] Rol agregado exitosamente');
      return true;
      
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  // ...existing code...
  Future<bool> signIn(String email, String password) async {
    print('🔄 [AuthController.signIn] Iniciando login para $email');
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _signInUseCase.execute(email, password);
      _state = AuthState.authenticated;
      print('✅ [AuthController.signIn] Login exitoso para usuario: ${_user?.id}');
      print('🔍 [AuthController.signIn] Estado: $_state');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ [AuthController.signIn] Error en login: $e');
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }Future<bool> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName1,
    String? lastName2,
    String? phone,
    String? address,
    String? roleSlug, // Añadido para manejar el rol
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _signUpUseCase.execute(
        email,
        password,
        firstName: firstName,
        lastName1: lastName1,
        lastName2: lastName2,
        phone: phone,
        address: address,
      );

      // Si se especifica un rol, agregarlo después del registro
      if (roleSlug != null) {
        await addRole(roleSlug);
      }

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
