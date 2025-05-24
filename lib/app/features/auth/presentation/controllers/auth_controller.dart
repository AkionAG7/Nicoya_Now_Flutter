import 'package:flutter/material.dart';
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

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;

  AuthController({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase;

  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  
  // Obtener el rol principal del usuario
  String? get userRole => _user?.role;
  
  // Obtener todos los roles del usuario como una lista
  List<String> get userRoles => _user?.getRoles() ?? ['client'];
  
  // Verificar si el usuario tiene un rol específico
  bool hasRole(String roleName) => _user?.hasRole(roleName) ?? false;

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
