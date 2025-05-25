
class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName1;
  final String? lastName2;
  final String? phone;
  final String role; 

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName1,
    this.lastName2,
    this.phone,
    this.role = 'customer', 
  });
  

  bool hasRole(String roleName) {
    if (role.isEmpty) return false;

    if (role.contains(',')) {
      final roles = role.split(',').map((r) => r.trim()).toList();
      return roles.contains(roleName);
    }
    

    return role.trim() == roleName;
  }
  
  List<String> getRoles() {
    if (role.isEmpty) return ['customer']; 
    
    if (role.contains(',')) {
      return role.split(',')
          .map((r) => r.trim())
          .where((r) => r.isNotEmpty)
          .toList();
    }
    
    return [role.trim()];
  }
}
