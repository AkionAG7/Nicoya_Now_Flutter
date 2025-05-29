import 'package:flutter/material.dart';
import 'package:nicoya_now/app/core/services/role_service.dart';
import 'package:nicoya_now/app/features/auth/domain/entities/user.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/get_user_roles_usecase.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/add_user_role_usecase.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

enum RoleType {
  customer,
  driver,
  merchant
}

class AuthController extends ChangeNotifier {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final RoleService _roleService;
  final GetUserRolesUseCase _getUserRolesUseCase;
  final AddUserRoleUseCase _addUserRoleUseCase;

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  List<String> _availableRoles = [];

  AuthController({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required RoleService roleService,
    required GetUserRolesUseCase getUserRolesUseCase,
    required AddUserRoleUseCase addUserRoleUseCase,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _roleService = roleService,
        _getUserRolesUseCase = getUserRolesUseCase,
        _addUserRoleUseCase = addUserRoleUseCase;  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  RoleService get roleService => _roleService;
  List<String> get availableRoles => _availableRoles;
  
  // Obtener el rol principal del usuario
  String? get userRole => _user?.role;
    // Obtener todos los roles del usuario como una lista
  List<String> get userRoles => _user?.getRoles() ?? ['customer'];
    // Verificar si el usuario tiene un rol específico
  bool hasRole(String roleName) => _user?.hasRole(roleName) ?? false;

  // Método para refrescar los datos del usuario actual
  Future<void> _refreshUserData() async {
    if (_user != null) {
      // Use the repository to get fresh user data
      final refreshedUser = await _signInUseCase.repository.getCurrentUser();
      if (refreshedUser != null) {
        _user = refreshedUser;
      }
    }
  }

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
    notifyListeners();    try {
      _user = await _signUpUseCase.execute(
        email,
        password,
        firstName: firstName,
        lastName1: lastName1,
        lastName2: lastName2,
        phone: phone,
        address: address,      );
      
      await _roleService.addRoleIfNotExists('customer');
      
      await _refreshUserData();
      
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

  /// Specialized method for driver registration
  Future<bool> signUpDriver({
    required String email,
    required String password,
    required String firstName,
    required String lastName1,
    required String lastName2,
    required String phone,
    required String idNumber,
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
      );
      
      // Add driver role to the user
      await _roleService.addRoleIfNotExists('driver');
        // Update profile with driver-specific data
      await _signInUseCase.repository.updateProfile(_user!.id, {
        'id_number': idNumber,
      });
      
      await _refreshUserData();
      
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }  /// Specialized method for merchant registration
  Future<bool> signUpMerchant({
    required String email,
    required String password,
    required String firstName,
    required String lastName1,
    required String lastName2,
    required String phone,
    String? idNumber,
    String? businessName,
    String? corporateName,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {      // Intentamos primero con signIn para ver si el usuario existe
      bool userExists = false;
      try {
        // Solo intentamos iniciar sesión para comprobar si el usuario existe
        await _signInUseCase.execute(email, password);
        // Si llegamos aquí, el inicio de sesión fue exitoso
        userExists = true;
        _user = await _signInUseCase.repository.getCurrentUser();
      } catch (e) {
        // Si hay error al iniciar sesión, el usuario no existe o la contraseña es incorrecta
        // Vamos a crear un nuevo usuario
        userExists = false;
      }
      
      if (!userExists) {
        // Si el usuario no existe, lo creamos
        _user = await _signUpUseCase.execute(
          email,
          password,
          firstName: firstName,
          lastName1: lastName1,
          lastName2: lastName2,
          phone: phone,
        );
      }
      
      // Esperamos un momento para garantizar que el usuario esté completamente autenticado
      await Future.delayed(Duration(milliseconds: 500));
      
      // Forzamos autenticación válida obteniendo usuario actual si _user es nulo
      _user ??= await _signInUseCase.repository.getCurrentUser();
      
      // Validación explícita del estado de autenticación
      if (_user == null || _user!.id.isEmpty) {
        throw Exception('Usuario no autenticado correctamente');
      }
        // Creamos datos completos para el merchant
      Map<String, dynamic> merchantData = {
        'id_number': idNumber,
        'business_name': businessName ?? firstName, // Usar el nombre del negocio si está disponible
        'corporate_name': corporateName ?? '${lastName1} ${lastName2}', // Usar nombre corporativo si está disponible
      };
      
      // Usamos addRoleWithData para asegurar que el rol y los datos del comerciante se añadan
      await _roleService.addRoleWithData('merchant', merchantData);
      
      // Actualizar perfil con datos básicos si es necesario
      if (idNumber != null && idNumber.isNotEmpty) {
        await _signInUseCase.repository.updateProfile(_user!.id, {
          'id_number': idNumber,
        });
      }// Refrescamos los datos del usuario para reflejar el nuevo rol
      await _refreshUserData();
      
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
  
  /// Method to handle adding a new role to an existing user
  Future<bool> handleRoleAdditionFlow(String email, String password, RoleType roleType) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // First, validate user credentials by signing in
      _user = await _signInUseCase.execute(email, password);
      
      // Check if the user already has the requested role
      final userRoles = await _getUserRolesUseCase.execute(_user!.id);
      final roleSlug = _getRoleSlugFromType(roleType);
      
      if (userRoles.contains(roleSlug)) {
        _state = AuthState.error;
        _errorMessage = 'Ya tienes este rol asociado a tu cuenta';
        notifyListeners();
        return false;
      }
      
      // At this point, user is authenticated but does not have the requested role
      _state = AuthState.authenticated;
      notifyListeners();
      
      // Return true to indicate successful authentication
      // The UI flow will continue to the role-specific data collection
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  /// Method to add a new role to the current authenticated user
  Future<bool> addRoleToCurrentUser(RoleType roleType, Map<String, dynamic> roleData) async {
    if (_user == null) {
      _errorMessage = 'No hay un usuario autenticado';
      return false;
    }
    
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final roleSlug = _getRoleSlugFromType(roleType);
      
      // Always set owner_id for merchant roles to prevent null constraint violations
      if (roleType == RoleType.merchant) {
        roleData['owner_id'] = _user!.id;
        print("Setting owner_id to ${_user!.id} for merchant role");
      }
      
      // Check if the user already has this role
      final userRoles = await _getUserRolesUseCase.execute(_user!.id);
      
      if (userRoles.contains(roleSlug)) {
        // If user already has the role, update the data instead of adding it
        if (roleType == RoleType.merchant) {
          // For merchants, ensure we have all required data
          await _roleService.addRoleWithData(roleSlug, roleData);
        } else {
          // For other roles, simply update the necessary data
          await _addUserRoleUseCase.execute(_user!.id, roleSlug, roleData);
        }
      } else {
        // If user doesn't have the role yet, add it with the corresponding data
        await _addUserRoleUseCase.execute(_user!.id, roleSlug, roleData);
      }
      
      // Refresh user data to get updated roles
      await _refreshUserData();
      
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
  
  /// Method to handle login with role selection if user has multiple roles
  Future<bool> handleLoginWithRoleSelection(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Sign in the user
      _user = await _signInUseCase.execute(email, password);
      
      // Get all roles for this user
      _availableRoles = await _getUserRolesUseCase.execute(_user!.id);
      
      // If user has only one role, just log them in normally
      if (_availableRoles.length <= 1) {
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      }
      
      // Otherwise, user has multiple roles, so signal that role selection is needed
      // but still mark them as authenticated
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
    // Helper method to convert role type enum to string slug
  String _getRoleSlugFromType(RoleType roleType) {
    switch (roleType) {
      case RoleType.customer:
        return 'customer';
      case RoleType.driver:
        return 'driver';
      case RoleType.merchant:
        return 'merchant';
    }
  }
}
