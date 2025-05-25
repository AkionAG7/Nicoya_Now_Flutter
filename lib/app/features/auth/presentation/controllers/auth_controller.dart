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
  }

  // Agregar un nuevo rol al usuario
  Future<void> addRole(String slug) async {
    await _roleService.addRoleIfNotExists(slug);
    await loadUserRoles(); // Recargar los roles después de agregar uno nuevo
  }

  // ...existing code...
  Future<bool> signIn(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _signInUseCase.execute(email, password);
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

  Future<bool> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName1,
    String? lastName2,
    String? phone,
    String? address,
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
