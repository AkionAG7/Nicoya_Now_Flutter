// User entity - Modelo de dominio independiente de la fuente de datos
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
    this.role = 'client', 
  });
}
