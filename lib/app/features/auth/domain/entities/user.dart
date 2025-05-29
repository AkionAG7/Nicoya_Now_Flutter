// User entity - Modelo de dominio independiente de la fuente de datos
class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName1;
  final String? lastName2;
  final String? phone;
  final String role; // Puede contener múltiples roles separados por coma: "client,driver,merchant"
  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName1,
    this.lastName2,
    this.phone,
    this.role = '', // No asignamos un rol por defecto
  });
    // Método para verificar si el usuario tiene un rol específico
  bool hasRole(String roleName) {
    if (role.isEmpty) return false;
    
    // Si el rol contiene comas, dividirlo y verificar si contiene el rol buscado
    if (role.contains(',')) {
      final roles = role.split(',').map((r) => r.trim()).toList();
      return roles.contains(roleName);
    }
    
    // Si solo hay un rol, compararlo directamente
    return role.trim() == roleName;
  }
  
  // DEBUG: Añadir toString para depuración
  @override
  String toString() {
    return 'User(id: $id, email: $email, role: "$role", roles: ${getRoles()})';
  }
  
  // Método para obtener la lista de roles del usuario
  List<String> getRoles() {
    if (role.isEmpty) return []; // NO asignamos un rol por defecto
    
    if (role.contains(',')) {
      return role.split(',')
          .map((r) => r.trim())
          .where((r) => r.isNotEmpty)
          .toList();
    }
    
    return [role.trim()];
  }
}
